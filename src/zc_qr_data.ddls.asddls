@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'QR Data - Projection View'
@Metadata.allowExtensions: true
define view entity ZC_QR_DATA 
  as projection on ZI_QR_DATA 
{
  key QrId,
      BadgeId,
      QrPayload,
      
      @Semantics.mimeType: true
      MimeType,
      
      @Semantics.largeObject: {
          mimeType: 'MimeType',
          fileName: 'QrId',
          contentDispositionPreference: #INLINE,
          acceptableMimeTypes: ['image/png', 'image/jpeg', 'image/*'] /* Force Image Mode */
      }
      QrImage,
      
      CreatedBy,
      CreatedAt,
      
      /* This is now allowed because there is no provider contract here */
      _Badge : redirected to parent ZC_BADGE_HDR
}


