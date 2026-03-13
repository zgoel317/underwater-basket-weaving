export interface ImageMetadata {
  width: number;
  height: number;
  size: number;
  format: string;
}

export interface ProcessedImage {
  id: string;
  original: string;
  thumbnail: string;
  medium: string;
  large: string;
  metadata: ImageMetadata;
}

export interface ImageUploadRequest {
  userId: string;
  type: 'profile' | 'basket' | 'dive';
  depth?: number;
}

export type ImageSize = 'thumb' | 'medium' | 'large' | 'original';
export type ImageType = 'profile' | 'basket' | 'dive';