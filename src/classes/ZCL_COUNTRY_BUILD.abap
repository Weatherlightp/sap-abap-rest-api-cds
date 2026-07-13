CLASS zcl_country_build DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  " -------------------------------------------------------------------------------------------------
  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.


    "------------------------------------------------
    " FLAT OUTPUT PART
    "------------------------------------------------

    " flat structure for console output and later database mapping

    TYPES: BEGIN OF ty_country_flat,
                country_name        TYPE string,
                country_name_common TYPE string,
                code                TYPE string,
                capital             TYPE string,
                latitude            TYPE decfloat34,
                longitude           TYPE decfloat34,
                flag                TYPE string,
                population          TYPE int8,
                language            TYPE string,
              END OF ty_country_flat.



    " flat internal table type
    TYPES ty_country_flat_tab TYPE STANDARD TABLE OF ty_country_flat WITH EMPTY KEY.


    "--------------------------------------------------
    " Method declaration - build a flat table from the nested API table
    "--------------------------------------------------
    CLASS-METHODS get_flat_country_table
      RETURNING VALUE(rt_flat_countries) TYPE ty_country_flat_tab.


  "-----------------------------------------------------------------------------------------------------------------

  PRIVATE SECTION.

    "--------------------------------------------------
    " API response structure - this will store the JSON response before mapping these fields to my databases
    "--------------------------------------------------


    "defines a structure called ty_country_name. the API returns the country name in a nested format
    "names: official: Canada
    TYPES: BEGIN OF ty_country_name,
             common   TYPE string,
             official TYPE string,
           END OF ty_country_name.

    "defines a structure called ty_country_code. this is also nested
    "codes: alpha_3: CAN
    TYPES: BEGIN OF ty_country_code,
             alpha_3 TYPE string,
           END OF ty_country_code.

    "defines the structure for the coordinates. this is also nested.
    "capitals: coordinates: lat: 45.42 and lng: -75.7
    TYPES: BEGIN OF ty_country_capital_coord,
             lat TYPE decfloat34,
             lng TYPE decfloat34,
           END OF ty_country_capital_coord.

    "defines the structure for the name of the capital. this is also nested
    "capitals: name: Ottawa
    TYPES: BEGIN OF ty_country_capital,
             name        TYPE string,
             coordinates TYPE ty_country_capital_coord,
           END OF ty_country_capital.

    "defines an internal table. a country can have more than one capital. also, in the JSON file, capitals is an array [ ]
    TYPES ty_country_capital_tab TYPE STANDARD TABLE OF ty_country_capital WITH EMPTY KEY.


    "defines the structure for the flag information
    TYPES: BEGIN OF ty_country_flag,
             url_png TYPE string,
           END OF ty_country_flag.

    "defines the structure for the language information. countries can have more than one language. languages are an array [ ]
    "languages: name: English name: French ----- name: gets the names in english
    TYPES: BEGIN OF ty_country_language,
             name  TYPE string,
           END OF ty_country_language.

    "defines an internal table that holds many language records. a country can have more than a language.
    TYPES ty_country_language_tab TYPE STANDARD TABLE OF ty_country_language WITH EMPTY KEY.


    "this is the main structure for one country from the API
    TYPES: BEGIN OF ty_country_api,
             names      TYPE ty_country_name,
             codes      TYPE ty_country_code,
             capitals   TYPE ty_country_capital_tab,
             flag       TYPE ty_country_flag,
             population TYPE int8,
             languages  TYPE ty_country_language_tab,
           END OF ty_country_api.

    "this defines an internal table of the type ty_country_api to hold many countries
    TYPES ty_country_api_tab TYPE STANDARD TABLE OF ty_country_api WITH EMPTY KEY.


    "------------------------------------------------
    " WRAPPER PART - this maps "data" and "objects" that exist in the JSON nested response.
    " we need to map here the "meta" block aswell because of PAGINATION
    "------------------------------------------------

    " I CHANGED HERE - meta block for pagination
    TYPES: BEGIN OF ty_api_meta,
            total  TYPE i,
            count  TYPE i,
            limit  TYPE i,
            offset TYPE i,
            more   TYPE abap_bool,
        END OF ty_api_meta.


    "wrapper for the API response root node: data -> objects
    TYPES: BEGIN OF ty_api_data,
             objects TYPE ty_country_api_tab,
             meta    TYPE ty_api_meta,
           END OF ty_api_data.


    "full API response wrapper
    TYPES: BEGIN OF ty_api_response,
             data TYPE ty_api_data,
           END OF ty_api_response.


" ty_country_flat e ty_country_flat_tab estavam aqui e passaram para o public.


    "--------------------------------------------------
    " Method declaration - get the JSON payload in full.
    " Now with changes to make this accept offset and limit
    "--------------------------------------------------
    CLASS-METHODS get_full_payload
      IMPORTING
        iv_offset TYPE i
        iv_limit  TYPE i
      RETURNING VALUE(rv_json) TYPE string.

    "--------------------------------------------------
    " Method declaration - deserialize the payload into an internal table
    "--------------------------------------------------
    CLASS-METHODS get_country_table
      RETURNING VALUE(rt_countries) TYPE ty_country_api_tab.


" get_flat_country_table estava aqui e passou para o public.


ENDCLASS.




CLASS zcl_country_build IMPLEMENTATION.


  METHOD get_full_payload.

  "--------------------------------------------------
  " Method implementation - get the JSON payload in full.
  " Changed this to handle pagination
  "--------------------------------------------------

    DATA: lo_destination TYPE REF TO if_http_destination,
          lo_client      TYPE REF TO if_web_http_client,
          lo_response    TYPE REF TO if_web_http_response.

    CONSTANTS lc_api_key TYPE string VALUE 'YOUR KEY HERE'. " INSERT THE KEY HERE !

    TRY.
        " Full payload for one country using REST Countries v5
        " https://api.restcountries.com/countries/v5?q=portugal&pretty=1
        " If you want all countries, replace the URL with:
        " https://api.restcountries.com/countries/v5?pretty=1
        " 'https://api.restcountries.com/countries/v5?offset=250'

        lo_destination = cl_http_destination_provider=>create_by_url(
*         i_url = 'https://api.restcountries.com/countries/v5?offset=250' ).
          i_url = |https://api.restcountries.com/countries/v5?limit={ iv_limit }&offset={ iv_offset }| ).    " this is to handle the pagination.

        lo_client = cl_web_http_client_manager=>create_by_http_destination(
          i_destination = lo_destination ).

        lo_client->get_http_request( )->set_header_field(
          i_name  = 'Authorization'
          i_value = |Bearer { lc_api_key }| ).

        lo_client->get_http_request( )->set_header_field(
          i_name  = 'Accept'
          i_value = 'application/json' ).

        lo_response = lo_client->execute( if_web_http_client=>get ).

        rv_json = lo_response->get_text( ).

      CATCH cx_root INTO DATA(lx_error).
        rv_json = |ERROR: { lx_error->get_text( ) }|.
    ENDTRY.

  ENDMETHOD.


  METHOD get_country_table.

        DATA: lv_json     TYPE string,
              ls_response TYPE ty_api_response,
              lv_offset   TYPE i                 VALUE 0,
              lv_limit    TYPE i                 VALUE 100,
              lv_more     TYPE abap_bool         VALUE abap_true.

        CLEAR rt_countries.



        WHILE lv_more = abap_true.   "this is to handle the pagination. "more" is something that the api provides.

            lv_json = get_full_payload(
                                        iv_offset = lv_offset
                                        iv_limit = lv_limit ).


            TRY.

                    " deserialize the full payload wrapper first
                    /ui2/cl_json=>deserialize(
                      EXPORTING
                        json = lv_json
                      CHANGING
                        data = ls_response ).


                    " extract the country list from data->objects
                    APPEND LINES OF ls_response-data-objects TO rt_countries.

                    " read pagination flag from API response
                    lv_more = ls_response-data-meta-more.

                    " move to next page using the limit returned by API
                    lv_offset = lv_offset + ls_response-data-meta-limit.


                CATCH cx_root INTO DATA(lx_error).
                  CLEAR rt_countries.
                  lv_more = abap_false.

            ENDTRY.

        ENDWHILE.

  ENDMETHOD.



  METHOD get_flat_country_table.

  "--------------------------------------------------
  " new method to flatten the nested country table into a flat table
  "--------------------------------------------------

    DATA: lt_countries TYPE ty_country_api_tab,
          ls_country   TYPE ty_country_api,
          ls_flat      TYPE ty_country_flat,
          lv_language  TYPE string.


    lt_countries = get_country_table( ).

    LOOP AT lt_countries INTO ls_country.

        CLEAR: ls_flat, lv_language.

        ls_flat-country_name        = ls_country-names-official.       " official country name
        ls_flat-country_name_common = ls_country-names-common.         " common country name
        ls_flat-code                = ls_country-codes-alpha_3.        " alpha_3 code


        "-----------------------------------
        " all the capitals from the country.
        READ TABLE ls_country-capitals INTO DATA(ls_capital) INDEX 1.
        IF sy-subrc = 0.
            ls_flat-capital = ls_capital-name.
            ls_flat-latitude = ls_capital-coordinates-lat.
            ls_flat-longitude = ls_capital-coordinates-lng.
        ENDIF.
        "-----------------------------------


        ls_flat-flag       = ls_country-flag-url_png.     " flag png link
        ls_flat-population = ls_country-population.       " population


        "----------------------------------------------------------------
        " all language names into one string separated by commas
        LOOP AT ls_country-languages INTO DATA(ls_language).
            IF lv_language IS INITIAL.
                lv_language = ls_language-name.
            ELSE.
                lv_language = lv_language && ', ' && ls_language-name.
            ENDIF.
        ENDLOOP.

        ls_flat-language = lv_language.
        " ---------------------------------------------------------------


        APPEND ls_flat TO rt_flat_countries.

    ENDLOOP.

  ENDMETHOD.



  METHOD if_oo_adt_classrun~main.

    "--------------------------------------------------
    " Method implementation - if_oo_adt_classrun is what makes the code write into the console.
    "--------------------------------------------------

        DATA: lv_json       TYPE string,
              lt_countries  TYPE ty_country_api_tab,
*             lv_json_table TYPE string,
*             ls_response   TYPE ty_api_response.
              lt_flat       TYPE ty_country_flat_tab,
              lv_line       TYPE string.

        "1) Get the raw JSON payload. this is what i had before, but now has a title sayin RAW PAYLOAD
*        lv_json = get_full_payload( ).
*        out->write( |--------------------------------------------------------------------------------------------------------------------------------------------:| ).
*        out->write( |RAW PAYLOAD:| ).
*        out->write( lv_json ).


        "2) Deserialize the JSON into an internal table
        lt_countries = get_country_table( ).


        "3) Print the internal table as JSON so you can inspect it in the console
        /ui2/cl_json=>serialize(
          EXPORTING
              data        = lt_countries
              pretty_name = /ui2/cl_json=>pretty_mode-camel_case
          RECEIVING
              r_json = lv_json ).


*        out->write( | | ).
*        out->write( |MAPPED INTERNAL TABLE:| ).
*        out->write( lv_json ).


        "4) create the flattened table
        lt_flat = get_flat_country_table( ).


        " print the flattened table in a readable format
        out->write( | | ).
        out->write( |FLATTENED TABLE:| ).
        out->write( 'Country Official Name | Country Common Name | Country Code | Capital | Latitude | Longitude | Flag | Population | Languages' ). "

        LOOP AT lt_flat INTO DATA(ls_flat).

            CLEAR lv_line.

            lv_line = ls_flat-country_name.
            lv_line = lv_line && ` | ` && ls_flat-country_name_common.
            lv_line = lv_line && ` | ` && ls_flat-code.
            lv_line = lv_line && ` | ` && ls_flat-capital.
            lv_line = lv_line && ` | ` && |{ ls_flat-latitude }|.
            lv_line = lv_line && ` | ` && |{ ls_flat-longitude }|.
            lv_line = lv_line && ` | ` && ls_flat-flag.
            lv_line = lv_line && ` | ` && |{ ls_flat-population }|.
            lv_line = lv_line && ` | ` && ls_flat-language.

            out->write( lv_line ).

        ENDLOOP.

  ENDMETHOD.

ENDCLASS.