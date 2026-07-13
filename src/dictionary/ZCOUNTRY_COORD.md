@EndUserText.label : 'Country Coordenates Table'
@AbapCatalog.enhancement.category : #NOT_EXTENSIBLE
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #ALLOWED
define table zcountry_coord {

  key mandt : abap.clnt not null;
  key code  : abap.char(3) not null;
  latitude  : abap.dec(10,6);
  longitude : abap.dec(10,6);

}