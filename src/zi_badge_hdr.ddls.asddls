//@AccessControl.authorizationCheck: #NOT_REQUIRED
//@EndUserText.label: 'Badge Header - Interface View'
//define root view entity ZI_BADGE_HDR 
//  as select from ztb_badge_hdr
//  composition [0..*] of ZI_QR_DATA as _QRData
//{
//  key badge_id              as BadgeId,
//      full_name             as FullName,
//      badge_type            as BadgeType,
//      company_name          as CompanyName,
//      valid_from            as ValidFrom,
//      valid_to              as ValidTo,
//       @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_STATUS_V', element: 'StatusCode' } }]
//      status                as Status,
//      
//      // Administrative data
//      created_by            as CreatedBy,
//      created_at            as CreatedAt,
//      last_changed_by       as LastChangedBy,
//      last_changed_at       as LastChangedAt,
//      local_last_changed_at as LocalLastChangedAt,
//      
//      // Public association to child
//      _QRData
//}


@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Badge Header - Interface View'
define root view entity ZI_BADGE_HDR 
  as select from ztb_badge_hdr
  
  composition [0..*] of ZI_QR_DATA as _QRData
  
  /* ADDED: Direct association to fetch the single image from the DB */
  association [0..1] to ztb_qr_data as _SingleQR on $projection.BadgeId = _SingleQR.badge_id
{
  key badge_id              as BadgeId,
      full_name             as FullName,
      badge_type            as BadgeType,
      company_name          as CompanyName,
      valid_from            as ValidFrom,
      valid_to              as ValidTo,
      
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZI_STATUS_V', element: 'StatusCode' } }]
      status                as Status,
      
      /* ADDED: Pulling the Mime Type and QR Image */
      @Semantics.mimeType: true
      _SingleQR.mime_type   as QrMimeType,
      
      @Semantics.largeObject: {
          mimeType: 'QrMimeType',
          fileName: 'BadgeId',
          contentDispositionPreference: #INLINE,
          acceptableMimeTypes: ['image/png', 'image/jpeg', 'image/*']
      }
      _SingleQR.qr_image    as QrImage,
      
      // Administrative data
      created_by            as CreatedBy,
      created_at            as CreatedAt,
      last_changed_by       as LastChangedBy,
      last_changed_at       as LastChangedAt,
      local_last_changed_at as LocalLastChangedAt,
      
      // Public association to child
      _QRData,
      
      /* ADDED: Expose the new association */
      _SingleQR
}
