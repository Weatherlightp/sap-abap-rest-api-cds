CLASS zcl_country_orchestrator DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

  PRIVATE SECTION.

ENDCLASS.



CLASS zcl_country_orchestrator IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.

    "--------------------------------------------------
    " Orchestrator class:
    " 1) gets the flattened country table from the build class
    " 2) sends it to the save class
    " 3) prints the result in the console
    "--------------------------------------------------


" 1) get the flattened country table from ZCL_COUNTRY_BUILD

    DATA: lt_flat       TYPE zcl_country_build=>ty_country_flat_tab,
          lv_save_msg   TYPE string,
          lv_row_count  TYPE i.


    lt_flat = zcl_country_build=>get_flat_country_table( ).

    "show how many rows were built

    lv_row_count = lines( lt_flat ).
    out->write( |Rows returned by build class: { lines( lt_flat ) }| ).
    out->write( |Rows returned by build class: { lv_row_count }| ).


" 2) send the flat table to the save class

    lv_save_msg = zcl_country_save=>save_country_tables( lt_flat ).


" 3) print the save result

    out->write( |SAVE RESULT:| ).
    out->write( lv_save_msg ).


  ENDMETHOD.

ENDCLASS.