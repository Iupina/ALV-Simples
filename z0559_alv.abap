REPORT z0559_alv.

TYPES: BEGIN OF lty_vbak,
         vbeln TYPE vbeln_va,
         erdat TYPE erdat,
         erzet TYPE erzet,
         ernam TYPE ernam,
         vbtyp TYPE vbtypl,
       END OF lty_vbak.

DATA: lt_vbak TYPE TABLE OF lty_vbak,
      ls_vbak TYPE lty_vbak.

TYPES: BEGIN OF lty_vbap,
         vbeln TYPE vbeln_va,
         posnr TYPE posnr_va,
         matnr TYPE matnr,
       END OF lty_vbap.

DATA: lt_vbap TYPE TABLE OF lty_vbap,
      ls_vbap TYPE lty_vbap.

DATA: lv_vbeln    TYPE vbeln_va,
      lt_fieldcat TYPE slis_t_fieldcat_alv,
      lt_final    TYPE TABLE OF zstr_vendas,
      ls_final    TYPE zstr_vendas.


SELECT-OPTIONS:s_vbeln FOR lv_vbeln.

SELECT vbeln erdat erzet ernam vbtyp
  FROM vbak
  INTO TABLE lt_vbak
  WHERE vbeln IN s_vbeln.

IF lt_vbak IS NOT INITIAL.
  SELECT vbeln posnr matnr
    FROM vbap
    INTO TABLE lt_vbap
    FOR ALL ENTRIES IN lt_vbak
    WHERE vbeln = lt_vbak-vbeln.
ENDIF.

LOOP AT lt_vbak INTO ls_vbak.
  LOOP AT lt_vbap INTO ls_vbap WHERE vbeln = ls_vbak-vbeln.
    ls_final-vbeln = ls_vbak-vbeln.
    ls_final-erdat = ls_vbak-erdat.
    ls_final-erzet = ls_vbak-erzet.
    ls_final-ernam = ls_vbak-ernam.
    ls_final-vbtyp = ls_vbak-vbtyp.
    ls_final-posnr = ls_vbap-posnr.
    ls_final-matnr = ls_vbap-matnr.

    APPEND ls_final TO lt_final.
    CLEAR ls_final.
  ENDLOOP.
ENDLOOP.

CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
  EXPORTING
    i_structure_name       = 'zstr_vendas' "estrutura criada na SE11
  CHANGING
    ct_fieldcat            = lt_fieldcat
  EXCEPTIONS
    inconsistent_interface = 1
    program_error          = 2
    OTHERS                 = 3.


CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
  EXPORTING
    it_fieldcat   = lt_fieldcat
  TABLES
    t_outtab      = lt_final
  EXCEPTIONS
    program_error = 1
    OTHERS        = 2.
