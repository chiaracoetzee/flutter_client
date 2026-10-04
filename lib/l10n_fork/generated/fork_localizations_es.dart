// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'fork_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class ForkLocalizationsEs extends ForkLocalizations {
  ForkLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get chatMessageChangePersona => 'Cambiar persona';

  @override
  String get chatAttachmentPanelVoice => 'Voz';

  @override
  String get advancedSettingQuickSwitcherButtonLabel =>
      'Botón del selector rápido';

  @override
  String get advancedSettingQuickSwitcherButtonDescription =>
      'Reemplaza el botón de mensaje de voz por un botón de selector rápido para una navegación ágil';

  @override
  String get userSettingsCheckForUpdates => 'Buscar actualizaciones';

  @override
  String get userSettingsCheckingForUpdates => 'Buscando actualizaciones…';

  @override
  String get userSettingsAppUpToDate => 'Fluxer está actualizado';

  @override
  String get userSettingsUpdateAvailableTitle => 'Actualización disponible';

  @override
  String get userSettingsUpdateDownloadAction => 'Descargar e instalar';

  @override
  String get userSettingsUpdateInstallAction => 'Instalar actualización';

  @override
  String userSettingsDownloadingUpdate(int percent) {
    return 'Descargando actualización ($percent %)…';
  }

  @override
  String get userSettingsUpdateFailed =>
      'Error al buscar o descargar la actualización.';

  @override
  String get personaSelectTitle => 'Seleccionar persona';

  @override
  String get personaSettingsHeader => 'Ajustes de personas';

  @override
  String get personaManageAction => 'Gestionar';

  @override
  String get personaSearchPlaceholder =>
      'Buscar personas, etiquetas, pronombres...';

  @override
  String get personaModeManual => 'Manual';

  @override
  String get personaModeLast => 'Usada por última vez';

  @override
  String get personaModeManualDescription =>
      'Envía siempre como la persona seleccionada hasta que se cambie.';

  @override
  String get personaModeLastDescription =>
      'Cambia automáticamente a la persona utilizada en tu último mensaje.';

  @override
  String get personaRecentHeader => 'PERSONAS RECIENTES';

  @override
  String personaAllHeader(int count) {
    return 'TODAS LAS PERSONAS ($count)';
  }

  @override
  String personaSearchResultsHeader(int count) {
    return 'RESULTADOS DE BÚSQUEDA ($count)';
  }

  @override
  String get personaRootAccountLabel => 'Cuenta principal (Por defecto)';

  @override
  String get personaEmptyState =>
      'Aún no hay ninguna persona configurada. Crea una desde Gestionar personas.';

  @override
  String get personaEmptySearch => 'No se encontraron personas que coincidan.';

  @override
  String get personaEditTitle => 'Editar persona';

  @override
  String get personaCreateTitle => 'Crear persona';

  @override
  String get personaDisplayNameLabel => 'Nombre visible';

  @override
  String get personaPronounsLabel => 'Pronombres';

  @override
  String get personaPronounsHint => 'p. ej. ella/él';

  @override
  String get personaBioHint => 'Cuenta a los demás sobre esta persona...';

  @override
  String get personaUpdatedToast => 'Persona actualizada';

  @override
  String personaUpdateFailedToast(String error) {
    return 'Error al actualizar la persona: $error';
  }

  @override
  String get personaSectionTitle => 'Personas';

  @override
  String get personaDisplayNameHint => 'Nombre de la persona';

  @override
  String personaSendingAsTag(String name) {
    return 'Enviando como $name (Coincidencia por etiqueta)';
  }

  @override
  String personaSendingAsLatched(String name) {
    return 'Enviando como $name (Fijada)';
  }

  @override
  String personaSendingAsRoot(String username) {
    return 'Enviando como @$username';
  }

  @override
  String get personaMainAccount => 'Cuenta principal';

  @override
  String get personaEditPersona => 'Editar persona';

  @override
  String get userSettingsNavPersonas => 'Personas';

  @override
  String get personaSettingsDescription =>
      'Configura tu modo de persona activo, tu etiqueta de visualización personalizada y gestiona personas individuales.';

  @override
  String get personaDisplayTagSection => 'Etiqueta de visualización';

  @override
  String get personaDisplayTagDescription =>
      'La etiqueta de visualización aparecerá junto al nombre de todas las personas en los mensajes. Si no configuras ninguna, se mostrará la foto de perfil de tu cuenta.';

  @override
  String get personaDisplayTagLabel => 'Texto de la etiqueta de visualización';

  @override
  String get personaDisplayTagHint => 'p. ej. SYS';

  @override
  String get personaDisplayTagIconLabel =>
      'Icono de la etiqueta de visualización';

  @override
  String get personaUploadTagIcon => 'Subir icono';

  @override
  String get personaChangeTagIcon => 'Cambiar icono';

  @override
  String get personaRemoveTagIcon => 'Eliminar icono';

  @override
  String get personaChatPreviewTitle => 'Vista previa del chat';

  @override
  String get personaChatPreviewSampleMessage =>
      '¡Hola! Esta es una vista previa de cómo se ven los mensajes con tu etiqueta de visualización y tu persona activa.';

  @override
  String get personaListTitle => 'Personas configuradas';

  @override
  String get personaAddButton => 'Añadir persona';

  @override
  String get personaActiveBadge => 'Activa';

  @override
  String get personaMakeActive => 'Activar';

  @override
  String get personaDeleteTitle => 'Eliminar persona';

  @override
  String personaDeleteMessage(String name) {
    return '¿Seguro que quieres eliminar \"$name\"? Esta acción no se puede deshacer.';
  }

  @override
  String get personaDeleteConfirm => 'Eliminar';

  @override
  String get personaDeletedToast => 'Persona eliminada';

  @override
  String get personaCreatedToast => 'Persona creada';

  @override
  String personaCreateFailedToast(String error) {
    return 'Error al crear la persona: $error';
  }

  @override
  String get personaChangeAvatar => 'Cambiar avatar';

  @override
  String get personaRemoveAvatar => 'Eliminar avatar';

  @override
  String get personaUploadAvatar => 'Subir avatar';

  @override
  String get personaTagsLabel => 'Etiquetas de persona';

  @override
  String get personaTagPrefixLabel => 'Prefijo';

  @override
  String get personaTagSuffixLabel => 'Sufijo';

  @override
  String get personaVisibilityLabel => 'Visibilidad';

  @override
  String get personaVisibilityUnlisted => 'Oculta';

  @override
  String get personaVisibilityPublic => 'Pública';

  @override
  String get personaVisibilityPrivate => 'Privada';

  @override
  String get personaNameRequired =>
      'Introduce un nombre para mostrar de la persona';

  @override
  String get personaNameTooLong =>
      'El nombre de la persona debe tener 100 caracteres o menos';

  @override
  String get personaTagPrefixTooLong =>
      'El prefijo de la etiqueta debe tener 32 caracteres o menos';

  @override
  String get personaTagSuffixTooLong =>
      'El sufijo de la etiqueta debe tener 32 caracteres o menos';

  @override
  String personaTagCollisionError(String tag, String name) {
    return 'La etiqueta \'$tag\' ya está en uso por \'$name\'.';
  }

  @override
  String get chatInsertTimestamp => 'Insertar marca de tiempo';

  @override
  String get timestampPickerTitle => 'Insertar marca de tiempo';

  @override
  String get timestampPickerInsert => 'Insertar';

  @override
  String get timestampCopied => 'Marca de tiempo copiada';

  @override
  String get timestampPickerTimeLabel => 'Hora';

  @override
  String get timestampPickerDateLabel => 'FECHA';

  @override
  String get timestampPickerTimeSectionLabel => 'HORA';

  @override
  String get timestampPickerTimezoneLabel => 'ZONA HORARIA';

  @override
  String get timestampPickerFormatPreviewLabel => 'VISTA PREVIA DEL FORMATO';

  @override
  String get timestampPickerNlpPlaceholder =>
      'ej. mañana a las 3pm, en 2 horas, ahora';

  @override
  String get timestampPickerSearchTimezones => 'Buscar zonas horarias...';

  @override
  String get userProfileTimezoneSettingLabel => 'Zona horaria';

  @override
  String get userProfileTimezoneSettingDescription =>
      'Se usa para mostrar tu hora local en tu perfil.';

  @override
  String get userProfileTimezoneNone => 'Ninguno';

  @override
  String get chatReactAs => 'Reaccionar como...';

  @override
  String get emojiCopy => 'Copiar emoji';

  @override
  String get emojiCopyLink => 'Copiar enlace';

  @override
  String get personaSignatureEmojisLabel => 'Emojis de firma';

  @override
  String get personaSignatureEmojisDescription =>
      'Reaccionar con un emoji de firma siempre reaccionará como esta persona, independientemente de la persona activa.';

  @override
  String get personaAddSignatureEmoji => 'Añadir emoji';

  @override
  String get personaSignatureEmojiAlreadyAdded =>
      'Este emoji ya está añadido como emoji de firma';

  @override
  String personaSignatureEmojiAlreadyUsedByOther(String name) {
    return 'El emoji de firma ya está en uso por la persona \"$name\"';
  }

  @override
  String get personaRemoveSignatureEmoji => 'Eliminar emoji de firma';

  @override
  String get signalBarLabel => 'Barra de señales';

  @override
  String get signalBarShow => 'Mostrar barra de señales';

  @override
  String get signalBarHide => 'Ocultar barra de señales';

  @override
  String signalBarSignalWithNames(String label, String names) {
    return '$label: $names';
  }

  @override
  String get signalBarNobody => 'Nadie tiene esta señal activada';

  @override
  String get signalBarReset => 'Restablecer señal para todos';
}

/// The translations for Spanish Castilian, as used in Latin America and the Caribbean (`es_419`).
class ForkLocalizationsEs419 extends ForkLocalizationsEs {
  ForkLocalizationsEs419() : super('es_419');

  @override
  String get chatMessageChangePersona => 'Cambiar persona';

  @override
  String get chatAttachmentPanelVoice => 'Voz';

  @override
  String get advancedSettingQuickSwitcherButtonLabel =>
      'Botón del selector rápido';

  @override
  String get advancedSettingQuickSwitcherButtonDescription =>
      'Reemplaza el botón de mensaje de voz por un botón de selector rápido para una navegación ágil';

  @override
  String get userSettingsCheckForUpdates => 'Buscar actualizaciones';

  @override
  String get userSettingsCheckingForUpdates => 'Buscando actualizaciones…';

  @override
  String get userSettingsAppUpToDate => 'Fluxer está actualizado';

  @override
  String get userSettingsUpdateAvailableTitle => 'Actualización disponible';

  @override
  String get userSettingsUpdateDownloadAction => 'Descargar e instalar';

  @override
  String get userSettingsUpdateInstallAction => 'Instalar actualización';

  @override
  String userSettingsDownloadingUpdate(int percent) {
    return 'Descargando actualización ($percent %)…';
  }

  @override
  String get userSettingsUpdateFailed =>
      'Error al buscar o descargar la actualización.';

  @override
  String get personaSelectTitle => 'Seleccionar persona';

  @override
  String get personaSettingsHeader => 'Configuración de personas';

  @override
  String get personaManageAction => 'Administrar';

  @override
  String get personaSearchPlaceholder =>
      'Buscar personas, etiquetas, pronombres...';

  @override
  String get personaModeManual => 'Manual';

  @override
  String get personaModeLast => 'Usada por última vez';

  @override
  String get personaModeManualDescription =>
      'Siempre envía como la persona seleccionada hasta que se cambie.';

  @override
  String get personaModeLastDescription =>
      'Cambia automáticamente a la persona utilizada en tu último mensaje.';

  @override
  String get personaRecentHeader => 'PERSONAS RECIENTES';

  @override
  String personaAllHeader(int count) {
    return 'TODAS LAS PERSONAS ($count)';
  }

  @override
  String personaSearchResultsHeader(int count) {
    return 'RESULTADOS DE BÚSQUEDA ($count)';
  }

  @override
  String get personaRootAccountLabel => 'Cuenta principal (Por defecto)';

  @override
  String get personaEmptyState =>
      'Aún no hay ninguna persona configurada. Crea una desde Administrar personas.';

  @override
  String get personaEmptySearch => 'No se encontraron personas que coincidan.';

  @override
  String get personaEditTitle => 'Editar persona';

  @override
  String get personaCreateTitle => 'Crear persona';

  @override
  String get personaDisplayNameLabel => 'Nombre visible';

  @override
  String get personaPronounsLabel => 'Pronombres';

  @override
  String get personaPronounsHint => 'ej. ella/él';

  @override
  String get personaBioHint => 'Cuéntale a los demás sobre esta persona...';

  @override
  String get personaUpdatedToast => 'Persona actualizada';

  @override
  String personaUpdateFailedToast(String error) {
    return 'Error al actualizar la persona: $error';
  }

  @override
  String get personaSectionTitle => 'Personas';

  @override
  String get personaDisplayNameHint => 'Nombre de la persona';

  @override
  String personaSendingAsTag(String name) {
    return 'Enviando como $name (Coincidencia por etiqueta)';
  }

  @override
  String personaSendingAsLatched(String name) {
    return 'Enviando como $name (Fijada)';
  }

  @override
  String personaSendingAsRoot(String username) {
    return 'Enviando como @$username';
  }

  @override
  String get personaMainAccount => 'Cuenta principal';

  @override
  String get personaEditPersona => 'Editar persona';

  @override
  String get userSettingsNavPersonas => 'Personas';

  @override
  String get personaSettingsDescription =>
      'Configura tu modo de persona activo, tu etiqueta de visualización personalizada y administra personas individuales.';

  @override
  String get personaDisplayTagSection => 'Etiqueta de visualización';

  @override
  String get personaDisplayTagDescription =>
      'La etiqueta de visualización aparecerá junto al nombre de todas las personas en los mensajes. Si no configuras ninguna, se mostrará la foto de perfil de tu cuenta.';

  @override
  String get personaDisplayTagLabel => 'Texto de la etiqueta de visualización';

  @override
  String get personaDisplayTagHint => 'ej. SYS';

  @override
  String get personaDisplayTagIconLabel =>
      'Ícono de la etiqueta de visualización';

  @override
  String get personaUploadTagIcon => 'Subir ícono';

  @override
  String get personaChangeTagIcon => 'Cambiar ícono';

  @override
  String get personaRemoveTagIcon => 'Quitar ícono';

  @override
  String get personaChatPreviewTitle => 'Vista previa del chat';

  @override
  String get personaChatPreviewSampleMessage =>
      '¡Hola! Esta es una vista previa de cómo se ven los mensajes con tu etiqueta de visualización y tu persona activa.';

  @override
  String get personaListTitle => 'Personas configuradas';

  @override
  String get personaAddButton => 'Agregar persona';

  @override
  String get personaActiveBadge => 'Activa';

  @override
  String get personaMakeActive => 'Activar';

  @override
  String get personaDeleteTitle => 'Eliminar persona';

  @override
  String personaDeleteMessage(String name) {
    return '¿Seguro que quieres eliminar \"$name\"? Esta acción no se puede deshacer.';
  }

  @override
  String get personaDeleteConfirm => 'Eliminar';

  @override
  String get personaDeletedToast => 'Persona eliminada';

  @override
  String get personaCreatedToast => 'Persona creada';

  @override
  String personaCreateFailedToast(String error) {
    return 'Error al crear la persona: $error';
  }

  @override
  String get personaChangeAvatar => 'Cambiar avatar';

  @override
  String get personaRemoveAvatar => 'Eliminar avatar';

  @override
  String get personaUploadAvatar => 'Subir avatar';

  @override
  String get personaTagsLabel => 'Etiquetas de persona';

  @override
  String get personaTagPrefixLabel => 'Prefijo';

  @override
  String get personaTagSuffixLabel => 'Sufijo';

  @override
  String get personaVisibilityLabel => 'Visibilidad';

  @override
  String get personaVisibilityUnlisted => 'No listada';

  @override
  String get personaVisibilityPublic => 'Pública';

  @override
  String get personaVisibilityPrivate => 'Privada';

  @override
  String get personaNameRequired =>
      'Ingresa un nombre para mostrar de la persona';

  @override
  String get personaNameTooLong =>
      'El nombre de la persona debe tener 100 caracteres o menos';

  @override
  String get personaTagPrefixTooLong =>
      'El prefijo de la etiqueta debe tener 32 caracteres o menos';

  @override
  String get personaTagSuffixTooLong =>
      'El sufijo de la etiqueta debe tener 32 caracteres o menos';

  @override
  String personaTagCollisionError(String tag, String name) {
    return 'La etiqueta \'$tag\' ya está en uso por \'$name\'.';
  }

  @override
  String get chatInsertTimestamp => 'Insertar marca de tiempo';

  @override
  String get timestampPickerTitle => 'Insertar marca de tiempo';

  @override
  String get timestampPickerInsert => 'Insertar';

  @override
  String get timestampCopied => 'Marca de tiempo copiada';

  @override
  String get timestampPickerTimeLabel => 'Hora';

  @override
  String get timestampPickerDateLabel => 'FECHA';

  @override
  String get timestampPickerTimeSectionLabel => 'HORA';

  @override
  String get timestampPickerTimezoneLabel => 'ZONA HORARIA';

  @override
  String get timestampPickerFormatPreviewLabel => 'VISTA PREVIA DEL FORMATO';

  @override
  String get timestampPickerNlpPlaceholder =>
      'ej. mañana a las 3pm, en 2 horas, ahora';

  @override
  String get timestampPickerSearchTimezones => 'Buscar zonas horarias...';

  @override
  String get userProfileTimezoneSettingLabel => 'Zona horaria';

  @override
  String get userProfileTimezoneSettingDescription =>
      'Se usa para mostrar tu hora local en tu perfil.';

  @override
  String get userProfileTimezoneNone => 'Ninguno';

  @override
  String get signalBarLabel => 'Barra de señales';

  @override
  String get signalBarShow => 'Mostrar barra de señales';

  @override
  String get signalBarHide => 'Ocultar barra de señales';

  @override
  String signalBarSignalWithNames(String label, String names) {
    return '$label: $names';
  }

  @override
  String get signalBarNobody => 'Nadie tiene esta señal activada';

  @override
  String get signalBarReset => 'Restablecer señal para todos';
}
