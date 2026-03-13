import AWS from 'aws-sdk';
import sharp from 'sharp';
import { v4 as uuidv4 } from 'uuid';

interface ImageResolution {
  width: number;
  height: number;
  suffix: string;
}

interface ProcessedImage {
  id: string;
  original: string;
  thumbnail: string;
  medium: string;
  large: string;
  metadata: {
    width: number;
    height: number;
    size: number;
    format: string;
  };
}

class ImageService {
  private s3: AWS.S3;
  private cloudfront: string;
  private bucket: string;
  
  private resolutions: ImageResolution[] = [
    { width: 150, height: 150, suffix: 'thumb' },
    { width: 400, height: 300, suffix: 'medium' },
    { width: 1200, height: 900, suffix: 'large' }
  ];

  constructor() {
    this.s3 = new AWS.S3({
      accessKeyId: process.env.AWS_ACCESS_KEY_ID,
      secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
      region: process.env.AWS_REGION
    });
    this.cloudfront = process.env.CLOUDFRONT_DOMAIN!;
    this.bucket = process.env.S3_BUCKET!;
  }

  async uploadAndProcess(buffer: Buffer, userId: string, type: 'profile' | 'basket' | 'dive'): Promise<ProcessedImage> {
    const imageId = uuidv4();
    const prefix = `images/${userId}/${type}/${imageId}`;
    
    const originalMetadata = await sharp(buffer).metadata();
    
    const optimizedOriginal = await sharp(buffer)
      .jpeg({ quality: 85, progressive: true })
      .withMetadata()
      .toBuffer();

    const originalKey = `${prefix}/original.jpg`;
    await this.uploadToS3(optimizedOriginal, originalKey, 'image/jpeg');

    const processedVersions: { [key: string]: string } = {};
    
    for (const resolution of this.resolutions) {
      const resizedBuffer = await sharp(buffer)
        .resize(resolution.width, resolution.height, {
          fit: 'cover',
          position: 'center'
        })
        .jpeg({ quality: 80, progressive: true })
        .toBuffer();
      
      const key = `${prefix}/${resolution.suffix}.jpg`;
      await this.uploadToS3(resizedBuffer, key, 'image/jpeg');
      processedVersions[resolution.suffix] = `${this.cloudfront}/${key}`;
    }

    return {
      id: imageId,
      original: `${this.cloudfront}/${originalKey}`,
      thumbnail: processedVersions.thumb,
      medium: processedVersions.medium,
      large: processedVersions.large,
      metadata: {
        width: originalMetadata.width || 0,
        height: originalMetadata.height || 0,
        size: optimizedOriginal.length,
        format: originalMetadata.format || 'jpeg'
      }
    };
  }

  async uploadUnderwaterPhoto(buffer: Buffer, userId: string, depth?: number): Promise<ProcessedImage> {
    const enhancedBuffer = await this.enhanceUnderwaterPhoto(buffer, depth);
    return this.uploadAndProcess(enhancedBuffer, userId, 'dive');
  }

  private async enhanceUnderwaterPhoto(buffer: Buffer, depth?: number): Promise<Buffer> {
    let processor = sharp(buffer);
    
    if (depth && depth > 10) {
      processor = processor
        .modulate({
          brightness: 1.1,
          saturation: 1.2
        })
        .gamma(1.1);
    }
    
    return processor
      .sharpen()
      .toBuffer();
  }

  private async uploadToS3(buffer: Buffer, key: string, contentType: string): Promise<void> {
    const params = {
      Bucket: this.bucket,
      Key: key,
      Body: buffer,
      ContentType: contentType,
      CacheControl: 'max-age=31536000',
      ACL: 'public-read'
    };
    
    await this.s3.upload(params).promise();
  }

  async deleteImage(imageId: string, userId: string, type: 'profile' | 'basket' | 'dive'): Promise<void> {
    const prefix = `images/${userId}/${type}/${imageId}`;
    const keys = [
      `${prefix}/original.jpg`,
      `${prefix}/thumb.jpg`,
      `${prefix}/medium.jpg`,
      `${prefix}/large.jpg`
    ];

    const deletePromises = keys.map(key => 
      this.s3.deleteObject({ Bucket: this.bucket, Key: key }).promise()
    );
    
    await Promise.all(deletePromises);
  }

  getImageUrl(imageId: string, userId: string, type: 'profile' | 'basket' | 'dive', size: 'thumb' | 'medium' | 'large' | 'original' = 'medium'): string {
    return `${this.cloudfront}/images/${userId}/${type}/${imageId}/${size}.jpg`;
  }
}

export default new ImageService();