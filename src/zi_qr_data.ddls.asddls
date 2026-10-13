@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'QR Data - Interface View'
define view entity ZI_QR_DATA 
  as select from ztb_qr_data
  association to parent ZI_BADGE_HDR as _Badge on $projection.BadgeId = _Badge.BadgeId
{
  key qr_id                 as QrId,
      badge_id              as BadgeId,
      
      qr_payload            as QrPayload,
      
      @Semantics.mimeType: true
      mime_type             as MimeType,
      
      @Semantics.largeObject: { 
          mimeType: 'MimeType', 
          acceptableMimeTypes: ['image/png', 'image/jpeg'], 
          contentDispositionPreference: #INLINE 
      }
      qr_image              as QrImage,
      
      created_by            as CreatedBy,
      created_at            as CreatedAt,
      
      // Public association to parent
      _Badge
}
