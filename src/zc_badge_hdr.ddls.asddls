//@AccessControl.authorizationCheck: #NOT_REQUIRED
//@EndUserText.label: 'Badge Header - Projection View'
//@Metadata.allowExtensions: true
//define root view entity ZC_BADGE_HDR 
//  provider contract transactional_query
//  as projection on ZI_BADGE_HDR 
//{
//  key BadgeId,
//      FullName,
//      BadgeType,
//      CompanyName,
//      ValidFrom,
//      ValidTo,
//      Status,
//      CreatedBy,
//      CreatedAt,
//      LastChangedBy,
//      LastChangedAt,
//      LocalLastChangedAt,
//      
//      /* Redirect to composition child */
//      _QRData : redirected to composition child ZC_QR_DATA
//}


@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Badge Header - Projection View'
@Metadata.allowExtensions: true
define root view entity ZC_BADGE_HDR 
  provider contract transactional_query
  as projection on ZI_BADGE_HDR 
{
  key BadgeId,
      FullName,
      BadgeType,
      CompanyName,
      ValidFrom,
      ValidTo,
      Status,
      
      /* 1. Add the pulled QR fields here! */
      @UI.hidden: true
      QrMimeType,
      
      @Semantics.largeObject: {
          mimeType: 'QrMimeType',
          fileName: 'BadgeId',
          contentDispositionPreference: #INLINE,
          acceptableMimeTypes: ['image/png', 'image/jpeg', 'image/*']
      }
      QrImage,
      
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,
      
      _QRData : redirected to composition child ZC_QR_DATA
}
