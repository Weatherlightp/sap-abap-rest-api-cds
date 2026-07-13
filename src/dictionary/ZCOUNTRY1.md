@EndUserText.label : 'Country Master Data Table'
@AbapCatalog.enhancement.category : #NOT_EXTENSIBLE
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #ALLOWED
define table zcountry1 {

  key mandt    : abap.clnt not null;
  key code     : abap.char(3) not null;
  common_name  : abap.char(100);
  country_name : abap.char(100);
  capital      : abap.char(100);
  flag         : abap.char(255);
  population   : abap.int8;
  language     : abap.char(200);

}