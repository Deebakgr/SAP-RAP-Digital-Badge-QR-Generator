*"! <p class="shorttext synchronized" lang="en">Utility Class for Badge and QR Operations</p>
*CLASS zcl_badge_utility DEFINITION
*  PUBLIC
*  FINAL
*  CREATE PUBLIC .
*
*  PUBLIC SECTION.
*
*    "! <p class="shorttext synchronized" lang="en">Generates a QR Code Image from an external API</p>
*    "! @parameter iv_badge_id | <p class="shorttext synchronized" lang="en">Badge ID to encode</p>
*    "! @parameter ev_qr_image | <p class="shorttext synchronized" lang="en">Binary image data (PNG)</p>
*    "! @parameter ev_mime_type | <p class="shorttext synchronized" lang="en">MIME type (image/png)</p>
*    "! @parameter ev_payload | <p class="shorttext synchronized" lang="en">The text encoded in the QR</p>
*    CLASS-METHODS generate_qr_code
*      IMPORTING
*        iv_badge_id  TYPE string
*      EXPORTING
*        ev_qr_image  TYPE xstring
*        ev_mime_type TYPE string
*        ev_payload   TYPE string .
*
*  PROTECTED SECTION.
*  PRIVATE SECTION.
*ENDCLASS.
*
*
*CLASS zcl_badge_utility IMPLEMENTATION.
*
*  METHOD generate_qr_code.
*    " 1. Define the payload format
*    ev_payload = |BADGE_ID:{ iv_badge_id }|.
*    ev_mime_type = 'image/png'.
*    CLEAR ev_qr_image.
*
*    " 2. URL Encode the payload in case the Badge ID has spaces or special characters
*    DATA(lv_encoded_payload) = cl_web_http_utility=>escape_url( ev_payload ).
*
*    " 3. Call External QR Code API (api.qrserver.com)
*    TRY.
*        " Create HTTP Destination
*        DATA(lo_dest) = cl_http_destination_provider=>create_by_url( 'https://api.qrserver.com' ).
*
*        " Create HTTP Client
*        DATA(lo_http) = cl_web_http_client_manager=>create_by_http_destination( lo_dest ).
*
*        " Create Request
*        DATA(lo_req)  = lo_http->get_http_request( ).
*
*        " Set URI Path with size and encoded payload
*        lo_req->set_uri_path( |/v1/create-qr-code/?size=250x250&data={ lv_encoded_payload }| ).
*
*        " Execute GET Request
*        DATA(lo_resp) = lo_http->execute( i_method = if_web_http_client=>get ).
*
*        " 4. Retrieve the Binary Image (xstring)
*        IF lo_resp->get_status( )-code = 200.
*          ev_qr_image = lo_resp->get_binary( ).
*        ENDIF.
*
*      CATCH cx_http_dest_provider_error INTO DATA(lx_dest).
*        " Handle Destination Error (Log it in a real scenario)
*      CATCH cx_web_http_client_error INTO DATA(lx_http).
*        " Handle HTTP Execution Error (Log it in a real scenario)
*      CATCH cx_root INTO DATA(lx_root).
*        " Catch-all for any other exceptions
*    ENDTRY.
*
*  ENDMETHOD.
*
*ENDCLASS.



CLASS zcl_badge_utility DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    CLASS-METHODS generate_qr_code
      IMPORTING
        iv_qr_text   TYPE string   " <--- Changed from iv_badge_id
      EXPORTING
        ev_qr_image  TYPE xstring
        ev_mime_type TYPE string
        ev_payload   TYPE string .
ENDCLASS.

CLASS zcl_badge_utility IMPLEMENTATION.

  METHOD generate_qr_code.
    " 1. Use the full text passed from the SAVE method
    ev_payload   = iv_qr_text.
    ev_mime_type = 'image/png'.
    CLEAR ev_qr_image.

    " 2. URL Encode the payload so spaces, commas, and colons don't break the API
    DATA(lv_encoded_payload) = cl_web_http_utility=>escape_url( ev_payload ).

    " 3. Call External QR Code API
    TRY.
        DATA(lo_dest) = cl_http_destination_provider=>create_by_url( 'https://api.qrserver.com' ).
        DATA(lo_http) = cl_web_http_client_manager=>create_by_http_destination( lo_dest ).
        DATA(lo_req)  = lo_http->get_http_request( ).

        lo_req->set_uri_path( |/v1/create-qr-code/?size=250x250&data={ lv_encoded_payload }| ).
        DATA(lo_resp) = lo_http->execute( i_method = if_web_http_client=>get ).

        IF lo_resp->get_status( )-code = 200.
          ev_qr_image = lo_resp->get_binary( ).
        ENDIF.

      CATCH cx_root.
        " Handle API error silently or log it
    ENDTRY.
  ENDMETHOD.

ENDCLASS.
