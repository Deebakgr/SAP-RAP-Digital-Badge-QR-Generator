CLASS lcl_buffer DEFINITION.
  PUBLIC SECTION.
    CLASS-DATA: gt_badge_create TYPE TABLE OF ztb_badge_hdr,
                gt_badge_update TYPE TABLE OF ztb_badge_hdr,
                gt_badge_delete TYPE TABLE OF ztb_badge_hdr,
                gt_qr_create    TYPE TABLE OF ztb_qr_data,
                gt_qr_update    TYPE TABLE OF ztb_qr_data,
                gt_qr_delete    TYPE TABLE OF ztb_qr_data.
ENDCLASS.

CLASS lhc_Badge DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION keys REQUEST requested_authorizations FOR Badge RESULT result.
    METHODS create FOR MODIFY entities FOR CREATE Badge.
    METHODS update FOR MODIFY entities FOR UPDATE Badge.
    METHODS delete FOR MODIFY keys FOR DELETE Badge.
    METHODS read FOR READ keys FOR READ Badge RESULT result.
    METHODS lock FOR LOCK keys FOR LOCK Badge.
    METHODS rba_Qrdata FOR READ keys_rba FOR READ Badge\_Qrdata FULL result_requested RESULT result LINK association_links.
    METHODS cba_Qrdata FOR MODIFY entities_cba FOR CREATE Badge\_Qrdata.
    METHODS GenerateQRCode FOR MODIFY IMPORTING keys FOR ACTION Badge~GenerateQRCode RESULT result.
ENDCLASS.

CLASS lhc_Badge IMPLEMENTATION.

  METHOD get_instance_authorizations.
    LOOP AT keys INTO DATA(ls_key).
      APPEND VALUE #(
        %tky    = ls_key-%tky
        %update = if_abap_behv=>auth-allowed
        %delete = if_abap_behv=>auth-allowed
      ) TO result.
    ENDLOOP.
  ENDMETHOD.

  METHOD create.
    GET TIME STAMP FIELD DATA(lv_ts).

    LOOP AT entities INTO DATA(ls_entity).

      " 1. Default the Status to 'A' (Active) if the user leaves it blank
      DATA(lv_status) = ls_entity-Status.
      IF lv_status IS INITIAL.
        lv_status = 'A'.
      ENDIF.

      APPEND VALUE #(
        client                = sy-mandt
        badge_id              = ls_entity-BadgeId
        full_name             = ls_entity-FullName
        badge_type            = ls_entity-BadgeType
        company_name          = ls_entity-CompanyName
        valid_from            = ls_entity-ValidFrom
        valid_to              = ls_entity-ValidTo
        status                = lv_status

        " 2. Standard Creation Admin Data
        created_by            = sy-uname
        created_at            = lv_ts

        " 3. Initialize 'Last Changed' Admin Data so the UI fields aren't blank
        last_changed_by       = sy-uname
        last_changed_at       = lv_ts
        local_last_changed_at = lv_ts
      ) TO lcl_buffer=>gt_badge_create.

    ENDLOOP.
  ENDMETHOD.

  METHOD update.
    IF entities IS NOT INITIAL.
      SELECT * FROM ztb_badge_hdr
        FOR ALL ENTRIES IN @entities
        WHERE badge_id = @entities-BadgeId
        INTO TABLE @DATA(lt_db_badges).

      GET TIME STAMP FIELD DATA(lv_ts).

      LOOP AT entities INTO DATA(ls_update).
        READ TABLE lt_db_badges ASSIGNING FIELD-SYMBOL(<ls_db>) WITH KEY badge_id = ls_update-BadgeId.
        IF sy-subrc = 0.
          IF ls_update-%control-FullName     = if_abap_behv=>mk-on. <ls_db>-full_name    = ls_update-FullName. ENDIF.
          IF ls_update-%control-BadgeType    = if_abap_behv=>mk-on. <ls_db>-badge_type   = ls_update-BadgeType. ENDIF.
          IF ls_update-%control-CompanyName  = if_abap_behv=>mk-on. <ls_db>-company_name = ls_update-CompanyName. ENDIF.
          IF ls_update-%control-ValidFrom    = if_abap_behv=>mk-on. <ls_db>-valid_from   = ls_update-ValidFrom. ENDIF.
          IF ls_update-%control-ValidTo      = if_abap_behv=>mk-on. <ls_db>-valid_to     = ls_update-ValidTo. ENDIF.
          IF ls_update-%control-Status       = if_abap_behv=>mk-on. <ls_db>-status       = ls_update-Status. ENDIF.

          <ls_db>-last_changed_by = sy-uname.
          <ls_db>-last_changed_at = lv_ts.

          APPEND <ls_db> TO lcl_buffer=>gt_badge_update.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

  METHOD delete.
    LOOP AT keys INTO DATA(ls_key).
      APPEND VALUE #( badge_id = ls_key-BadgeId ) TO lcl_buffer=>gt_badge_delete.
    ENDLOOP.
  ENDMETHOD.

  METHOD read.
    IF keys IS NOT INITIAL.
      SELECT * FROM ztb_badge_hdr FOR ALL ENTRIES IN @keys
        WHERE badge_id = @keys-BadgeId
        INTO TABLE @DATA(lt_badge).

      LOOP AT lt_badge INTO DATA(ls_badge).
        APPEND VALUE #(
          %tky         = VALUE #( BadgeId = ls_badge-badge_id )
          BadgeId      = ls_badge-badge_id
          FullName     = ls_badge-full_name
          BadgeType    = ls_badge-badge_type
          CompanyName  = ls_badge-company_name
          ValidFrom    = ls_badge-valid_from
          ValidTo      = ls_badge-valid_to
          Status       = ls_badge-status
        ) TO result.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

  METHOD rba_Qrdata.
    IF keys_rba IS NOT INITIAL.
      SELECT * FROM ztb_qr_data FOR ALL ENTRIES IN @keys_rba
        WHERE badge_id = @keys_rba-BadgeId
        INTO TABLE @DATA(lt_qr).

      LOOP AT lt_qr INTO DATA(ls_qr).
        APPEND VALUE #(
          %tky       = VALUE #( QrId = ls_qr-qr_id )
          QrId       = ls_qr-qr_id
          BadgeId    = ls_qr-badge_id
          QrPayload  = ls_qr-qr_payload
          MimeType   = ls_qr-mime_type
          QrImage    = ls_qr-qr_image
        ) TO result.

        APPEND VALUE #(
          source-%tky = VALUE #( BadgeId = ls_qr-badge_id )
          target-%tky = VALUE #( QrId = ls_qr-qr_id )
        ) TO association_links.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

  METHOD cba_Qrdata.
    LOOP AT entities_cba INTO DATA(ls_cba).
      LOOP AT ls_cba-%target INTO DATA(ls_target).
        APPEND VALUE #(
          client     = sy-mandt
          qr_id      = ls_target-QrId
          badge_id   = ls_cba-BadgeId
          qr_payload = ls_target-QrPayload
          mime_type  = ls_target-MimeType
          qr_image   = ls_target-QrImage
          created_by = sy-uname
        ) TO lcl_buffer=>gt_qr_create.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD GenerateQRCode.
    READ ENTITIES OF ZI_BADGE_HDR IN LOCAL MODE
      ENTITY Badge
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_badges).

    LOOP AT lt_badges INTO DATA(ls_badge).

      " 1. Build a rich payload containing all the badge details
      DATA(lv_payload) = |ID: { ls_badge-BadgeId }, Name: { ls_badge-FullName }, Company: { ls_badge-CompanyName }, Role: { ls_badge-BadgeType }|.

      " URL Encode the payload so spaces and special characters don't break the API request
      DATA(lv_encoded_payload) = cl_web_http_utility=>escape_url( lv_payload ).

      DATA lv_image TYPE xstring.
      DATA(lv_mime) = 'image/png'.

      " 2. Make the HTTP API Call directly
      TRY.
          DATA(lo_dest) = cl_http_destination_provider=>create_by_url( 'https://api.qrserver.com' ).
          DATA(lo_http) = cl_web_http_client_manager=>create_by_http_destination( lo_dest ).
          DATA(lo_req)  = lo_http->get_http_request( ).

          " Increased size to 300x300 for better scannability of longer text
          lo_req->set_uri_path( |/v1/create-qr-code/?size=300x300&data={ lv_encoded_payload }| ).
          DATA(lo_resp) = lo_http->execute( i_method = if_web_http_client=>get ).

          IF lo_resp->get_status( )-code = 200.
            lv_image = lo_resp->get_binary( ).
          ENDIF.
        CATCH cx_root.
          " If API fails, bypass to avoid dumping
      ENDTRY.

      " 3. Update the buffer with the generated image and the rich text payload
      MODIFY ENTITIES OF ZI_BADGE_HDR IN LOCAL MODE
        ENTITY Badge
        CREATE BY \_QRData
        FIELDS ( QrId QrPayload MimeType QrImage )
        WITH VALUE #( (
          %tky    = ls_badge-%tky
          %target = VALUE #( (
            %cid      = 'QR_GEN_CID'
            QrId      = ls_badge-BadgeId
            QrPayload = lv_payload
            MimeType  = lv_mime
            QrImage   = lv_image
          ) )
        ) ).
    ENDLOOP.

    " 4. Return result to the UI
    result = VALUE #( FOR badge IN lt_badges ( %tky = badge-%tky %param = badge ) ).
  ENDMETHOD.

ENDCLASS.

CLASS lhc_QrData DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS update FOR MODIFY entities FOR UPDATE QrData.
    METHODS delete FOR MODIFY keys FOR DELETE QrData.
    METHODS read FOR READ keys FOR READ QrData RESULT result.
    METHODS rba_Badge FOR READ keys_rba FOR READ QrData\_Badge FULL result_requested RESULT result LINK association_links.
ENDCLASS.

CLASS lhc_QrData IMPLEMENTATION.

  METHOD update.
    IF entities IS NOT INITIAL.
      SELECT * FROM ztb_qr_data FOR ALL ENTRIES IN @entities
        WHERE qr_id = @entities-QrId
        INTO TABLE @DATA(lt_db_qr).

      LOOP AT entities INTO DATA(ls_update).
        READ TABLE lt_db_qr ASSIGNING FIELD-SYMBOL(<ls_db>) WITH KEY qr_id = ls_update-QrId.
        IF sy-subrc = 0.
          IF ls_update-%control-QrPayload = if_abap_behv=>mk-on. <ls_db>-qr_payload = ls_update-QrPayload. ENDIF.
          IF ls_update-%control-MimeType  = if_abap_behv=>mk-on. <ls_db>-mime_type  = ls_update-MimeType. ENDIF.
          IF ls_update-%control-QrImage   = if_abap_behv=>mk-on. <ls_db>-qr_image   = ls_update-QrImage. ENDIF.

          APPEND <ls_db> TO lcl_buffer=>gt_qr_update.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

  METHOD delete.
    LOOP AT keys INTO DATA(ls_key).
      APPEND VALUE #( qr_id = ls_key-QrId ) TO lcl_buffer=>gt_qr_delete.
    ENDLOOP.
  ENDMETHOD.

  METHOD read.
    IF keys IS NOT INITIAL.
      SELECT * FROM ztb_qr_data FOR ALL ENTRIES IN @keys
        WHERE qr_id = @keys-QrId
        INTO TABLE @DATA(lt_qr).

      LOOP AT lt_qr INTO DATA(ls_qr).
        APPEND VALUE #(
          %tky       = VALUE #( QrId = ls_qr-qr_id )
          QrId       = ls_qr-qr_id
          BadgeId    = ls_qr-badge_id
          QrPayload  = ls_qr-qr_payload
          MimeType   = ls_qr-mime_type
          QrImage    = ls_qr-qr_image
        ) TO result.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

  METHOD rba_Badge.
    IF keys_rba IS NOT INITIAL.
      SELECT qr_id, badge_id FROM ztb_qr_data FOR ALL ENTRIES IN @keys_rba
        WHERE qr_id = @keys_rba-QrId
        INTO TABLE @DATA(lt_qr).

      IF lt_qr IS NOT INITIAL.
        SELECT * FROM ztb_badge_hdr FOR ALL ENTRIES IN @lt_qr
          WHERE badge_id = @lt_qr-badge_id
          INTO TABLE @DATA(lt_badge).

        LOOP AT lt_qr INTO DATA(ls_qr).
          READ TABLE lt_badge INTO DATA(ls_badge) WITH KEY badge_id = ls_qr-badge_id.
          IF sy-subrc = 0.
            APPEND VALUE #(
              %tky         = VALUE #( BadgeId = ls_badge-badge_id )
              BadgeId      = ls_badge-badge_id
              FullName     = ls_badge-full_name
              BadgeType    = ls_badge-badge_type
              CompanyName  = ls_badge-company_name
            ) TO result.

            APPEND VALUE #(
              source-%tky = VALUE #( QrId    = ls_qr-qr_id )
              target-%tky = VALUE #( BadgeId = ls_badge-badge_id )
            ) TO association_links.
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDIF.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_ZI_BADGE_HDR DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS finalize REDEFINITION.
    METHODS check_before_save REDEFINITION.
    METHODS save REDEFINITION.
    METHODS cleanup REDEFINITION.
    METHODS cleanup_finalize REDEFINITION.
ENDCLASS.

CLASS lsc_ZI_BADGE_HDR IMPLEMENTATION.

  METHOD finalize. ENDMETHOD.
  METHOD check_before_save. ENDMETHOD.

  METHOD save.
    IF lcl_buffer=>gt_badge_create IS NOT INITIAL.
      INSERT ztb_badge_hdr FROM TABLE @lcl_buffer=>gt_badge_create.
    ENDIF.

    IF lcl_buffer=>gt_badge_update IS NOT INITIAL.
      UPDATE ztb_badge_hdr FROM TABLE @lcl_buffer=>gt_badge_update.
    ENDIF.

    IF lcl_buffer=>gt_badge_delete IS NOT INITIAL.
      DELETE ztb_badge_hdr FROM TABLE @lcl_buffer=>gt_badge_delete.
    ENDIF.

    IF lcl_buffer=>gt_qr_create IS NOT INITIAL.
      LOOP AT lcl_buffer=>gt_qr_create ASSIGNING FIELD-SYMBOL(<ls_qr>).
        IF <ls_qr>-created_at IS INITIAL.
          GET TIME STAMP FIELD <ls_qr>-created_at.
        ENDIF.
      ENDLOOP.

      " CHANGE THIS LINE:
      MODIFY ztb_qr_data FROM TABLE @lcl_buffer=>gt_qr_create.
    ENDIF.

    IF lcl_buffer=>gt_qr_update IS NOT INITIAL.
      UPDATE ztb_qr_data FROM TABLE @lcl_buffer=>gt_qr_update.
    ENDIF.

    IF lcl_buffer=>gt_qr_delete IS NOT INITIAL.
      DELETE ztb_qr_data FROM TABLE @lcl_buffer=>gt_qr_delete.
    ENDIF.
  ENDMETHOD.

  METHOD cleanup.
    CLEAR lcl_buffer=>gt_badge_create.
    CLEAR lcl_buffer=>gt_badge_update.
    CLEAR lcl_buffer=>gt_badge_delete.
    CLEAR lcl_buffer=>gt_qr_create.
    CLEAR lcl_buffer=>gt_qr_update.
    CLEAR lcl_buffer=>gt_qr_delete.
  ENDMETHOD.

  METHOD cleanup_finalize. ENDMETHOD.

ENDCLASS.
