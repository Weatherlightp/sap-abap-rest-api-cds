CLASS zcl_country_save DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.


    "--------------------------------------------------
    " Method declaration - save the flat country table into the database
    "--------------------------------------------------
    CLASS-METHODS save_country_tables
      IMPORTING
        it_countries TYPE zcl_country_build=>ty_country_flat_tab
      RETURNING
        VALUE(rv_message) TYPE string.

ENDCLASS.



CLASS zcl_country_save IMPLEMENTATION.

  METHOD save_country_tables.

    DATA: ls_country1 TYPE zcountry1,
          ls_coord    TYPE zcountry_coord,
          lv_count    TYPE i.

    CLEAR lv_count.

    IF it_countries IS INITIAL.
      rv_message = 'No countries received to save.'.
      RETURN.
    ENDIF.

    LOOP AT it_countries INTO DATA(ls_flat).

      CLEAR: ls_country1, ls_coord.

      "--------------------------------------------------
      " Fill ZCOUNTRY1
      "--------------------------------------------------
      ls_country1-code         = ls_flat-code.
      ls_country1-common_name  = ls_flat-country_name_common.
      ls_country1-country_name = ls_flat-country_name.
      ls_country1-capital      = ls_flat-capital.
      ls_country1-flag         = ls_flat-flag.
      ls_country1-population   = ls_flat-population.
      ls_country1-language     = ls_flat-language.

      MODIFY zcountry1 FROM @ls_country1.

      "--------------------------------------------------
      " Fill ZCOUNTRY_COORD
      "--------------------------------------------------
      ls_coord-code      = ls_flat-code.
      ls_coord-latitude  = ls_flat-latitude.
      ls_coord-longitude = ls_flat-longitude.

      MODIFY zcountry_coord FROM @ls_coord.

      lv_count = lv_count + 1.

    ENDLOOP.

    COMMIT WORK.

    rv_message = |{ lv_count } country records inserted/updated successfully in ZCOUNTRY1 and ZCOUNTRY_COORD.|.

  ENDMETHOD.

ENDCLASS.