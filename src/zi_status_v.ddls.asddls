@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Value Help for Status'
/* THIS IS THE MAGIC ANNOTATION THAT CREATES A DROP-DOWN */
@ObjectModel.resultSet.sizeCategory: #XS 
define view entity ZI_STATUS_V 
  as select from DDCDS_CUSTOMER_DOMAIN_VALUE_T( p_domain_name: 'ZDO_STATUS' )
{
      @UI.hidden: true
  key domain_name,
  
      @UI.hidden: true
  key value_position,
  
      @EndUserText.label: 'Status Code'
  key value_low as StatusCode,
      
      @Semantics.text: true
      @EndUserText.label: 'Status'
      text as StatusText
}
