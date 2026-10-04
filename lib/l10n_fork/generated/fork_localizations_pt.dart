// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'fork_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class ForkLocalizationsPt extends ForkLocalizations {
  ForkLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get chatMessageChangePersona => 'Mudar persona';

  @override
  String get chatAttachmentPanelVoice => 'Voz';

  @override
  String get advancedSettingQuickSwitcherButtonLabel =>
      'Botão do seletor rápido';

  @override
  String get advancedSettingQuickSwitcherButtonDescription =>
      'Substitui o botão de mensagem de voz na entrada de texto por um seletor rápido para navegação veloz';

  @override
  String get userSettingsCheckForUpdates => 'Procurar atualizações';

  @override
  String get userSettingsCheckingForUpdates => 'A procurar atualizações…';

  @override
  String get userSettingsAppUpToDate => 'O Fluxer está atualizado';

  @override
  String get userSettingsUpdateAvailableTitle => 'Atualização disponível';

  @override
  String get userSettingsUpdateDownloadAction => 'Transferir e instalar';

  @override
  String get userSettingsUpdateInstallAction => 'Instalar atualização';

  @override
  String userSettingsDownloadingUpdate(int percent) {
    return 'A transferir atualização ($percent%)…';
  }

  @override
  String get userSettingsUpdateFailed =>
      'Falha ao procurar ou transferir a atualização.';

  @override
  String get personaSelectTitle => 'Selecionar persona';

  @override
  String get personaSettingsHeader => 'Configurações de personas';

  @override
  String get personaManageAction => 'Gerir';

  @override
  String get personaSearchPlaceholder =>
      'Pesquisar personas, tags, pronomes...';

  @override
  String get personaModeManual => 'Manual';

  @override
  String get personaModeLast => 'Última utilizada';

  @override
  String get personaModeManualDescription =>
      'Envia sempre como a persona selecionada até ser alterada.';

  @override
  String get personaModeLastDescription =>
      'Muda automaticamente para a persona utilizada na tua última mensagem.';

  @override
  String get personaRecentHeader => 'PERSONAS RECENTES';

  @override
  String personaAllHeader(int count) {
    return 'TODAS AS PERSONAS ($count)';
  }

  @override
  String personaSearchResultsHeader(int count) {
    return 'RESULTADOS DA PESQUISA ($count)';
  }

  @override
  String get personaRootAccountLabel => 'Conta principal (Padrão)';

  @override
  String get personaEmptyState =>
      'Nenhuma persona configurada ainda. Cria uma em Gerir personas.';

  @override
  String get personaEmptySearch => 'Nenhuma persona correspondente encontrada.';

  @override
  String get personaEditTitle => 'Editar persona';

  @override
  String get personaCreateTitle => 'Criar persona';

  @override
  String get personaDisplayNameLabel => 'Nome de exibição';

  @override
  String get personaPronounsLabel => 'Pronomes';

  @override
  String get personaPronounsHint => 'ex. ela/ele';

  @override
  String get personaBioHint => 'Conta aos outros sobre esta persona...';

  @override
  String get personaUpdatedToast => 'Persona atualizada';

  @override
  String personaUpdateFailedToast(String error) {
    return 'Falha ao atualizar a persona: $error';
  }

  @override
  String get personaSectionTitle => 'Personas';

  @override
  String get personaDisplayNameHint => 'Nome da persona';

  @override
  String personaSendingAsTag(String name) {
    return 'Enviando como $name (Correspondência por tag)';
  }

  @override
  String personaSendingAsLatched(String name) {
    return 'Enviando como $name (Fixada)';
  }

  @override
  String personaSendingAsRoot(String username) {
    return 'Enviando como @$username';
  }

  @override
  String get personaMainAccount => 'Conta principal';

  @override
  String get personaEditPersona => 'Editar persona';

  @override
  String get userSettingsNavPersonas => 'Personas';

  @override
  String get personaSettingsDescription =>
      'Configura o teu modo de persona ativo, a tua tag de exibição personalizada e gere personas individuais.';

  @override
  String get personaDisplayTagSection => 'Tag de exibição';

  @override
  String get personaDisplayTagDescription =>
      'A tag de exibição aparecerá ao lado do nome de todas as personas nas mensagens. Se nenhuma tag de exibição for definida, a foto de perfil da tua conta será exibida.';

  @override
  String get personaDisplayTagLabel => 'Texto da tag de exibição';

  @override
  String get personaDisplayTagHint => 'ex. SYS';

  @override
  String get personaDisplayTagIconLabel => 'Ícone da tag de exibição';

  @override
  String get personaUploadTagIcon => 'Carregar ícone';

  @override
  String get personaChangeTagIcon => 'Alterar ícone';

  @override
  String get personaRemoveTagIcon => 'Remover ícone';

  @override
  String get personaChatPreviewTitle => 'Pré-visualização do chat';

  @override
  String get personaChatPreviewSampleMessage =>
      'Olá! Esta é uma pré-visualização de como as mensagens aparecem com a tua tag de exibição e persona ativa.';

  @override
  String get personaListTitle => 'Personas configuradas';

  @override
  String get personaAddButton => 'Adicionar persona';

  @override
  String get personaActiveBadge => 'Ativo';

  @override
  String get personaMakeActive => 'Tornar ativa';

  @override
  String get personaDeleteTitle => 'Eliminar persona';

  @override
  String personaDeleteMessage(String name) {
    return 'Tens a certeza de que desejas eliminar \"$name\"? Esta ação não pode ser desfeita.';
  }

  @override
  String get personaDeleteConfirm => 'Eliminar';

  @override
  String get personaDeletedToast => 'Persona eliminada';

  @override
  String get personaCreatedToast => 'Persona criada';

  @override
  String personaCreateFailedToast(String error) {
    return 'Falha ao criar a persona: $error';
  }

  @override
  String get personaChangeAvatar => 'Alterar avatar';

  @override
  String get personaRemoveAvatar => 'Remover avatar';

  @override
  String get personaUploadAvatar => 'Carregar avatar';

  @override
  String get personaTagsLabel => 'Tags de persona';

  @override
  String get personaTagPrefixLabel => 'Prefixo';

  @override
  String get personaTagSuffixLabel => 'Sufixo';

  @override
  String get personaVisibilityLabel => 'Visibilidade';

  @override
  String get personaVisibilityUnlisted => 'Não listada';

  @override
  String get personaVisibilityPublic => 'Pública';

  @override
  String get personaVisibilityPrivate => 'Privada';

  @override
  String get personaNameRequired =>
      'Introduza um nome de exibição para a persona';

  @override
  String get personaNameTooLong =>
      'O nome da persona deve ter 100 carateres ou menos';

  @override
  String get personaTagPrefixTooLong =>
      'O prefixo da tag da persona deve ter 32 carateres ou menos';

  @override
  String get personaTagSuffixTooLong =>
      'O sufixo da tag da persona deve ter 32 carateres ou menos';

  @override
  String personaTagCollisionError(String tag, String name) {
    return 'A tag \'$tag\' já está a ser usada por \'$name\'.';
  }

  @override
  String get chatInsertTimestamp => 'Inserir carimbo de data/hora';

  @override
  String get timestampPickerTitle => 'Inserir carimbo de data/hora';

  @override
  String get timestampPickerInsert => 'Inserir';

  @override
  String get timestampCopied => 'Carimbo de data/hora copiado';

  @override
  String get timestampPickerTimeLabel => 'Hora';

  @override
  String get timestampPickerDateLabel => 'DATA';

  @override
  String get timestampPickerTimeSectionLabel => 'HORA';

  @override
  String get timestampPickerTimezoneLabel => 'FUSO HORÁRIO';

  @override
  String get timestampPickerFormatPreviewLabel => 'PRÉVIA DO FORMATO';

  @override
  String get timestampPickerNlpPlaceholder =>
      'ex.: amanhã às 15h, em 2 horas, agora';

  @override
  String get timestampPickerSearchTimezones => 'Pesquisar fusos horários...';

  @override
  String get userProfileTimezoneSettingLabel => 'Fuso horário';

  @override
  String get userProfileTimezoneSettingDescription =>
      'Usado para mostrar sua hora local em seu perfil.';

  @override
  String get userProfileTimezoneNone => 'Nenhum';

  @override
  String get chatReactAs => 'Reagir como...';

  @override
  String get emojiCopy => 'Copiar emoji';

  @override
  String get emojiCopyLink => 'Copiar link';

  @override
  String get personaSignatureEmojisLabel => 'Emojis de assinatura';

  @override
  String get personaSignatureEmojisDescription =>
      'Reagir com um emoji de assinatura sempre reagirá como esta persona, independentemente da persona ativa.';

  @override
  String get personaAddSignatureEmoji => 'Adicionar emoji';

  @override
  String get personaSignatureEmojiAlreadyAdded =>
      'Este emoji já foi adicionado como emoji de assinatura';

  @override
  String personaSignatureEmojiAlreadyUsedByOther(String name) {
    return 'O emoji de assinatura já está em uso pela persona \"$name\"';
  }

  @override
  String get personaRemoveSignatureEmoji => 'Remover emoji de assinatura';

  @override
  String get signalBarLabel => 'Barra de sinais';

  @override
  String get signalBarShow => 'Mostrar barra de sinais';

  @override
  String get signalBarHide => 'Ocultar barra de sinais';

  @override
  String signalBarSignalWithNames(String label, String names) {
    return '$label: $names';
  }

  @override
  String get signalBarNobody => 'Ninguém está com este sinal ligado';

  @override
  String get signalBarReset => 'Redefinir sinal para todos';

  @override
  String signalBarTurnOff(String name) {
    return 'Desligar $name';
  }
}

/// The translations for Portuguese, as used in Brazil (`pt_BR`).
class ForkLocalizationsPtBr extends ForkLocalizationsPt {
  ForkLocalizationsPtBr() : super('pt_BR');

  @override
  String get chatMessageChangePersona => 'Mudar persona';

  @override
  String get chatAttachmentPanelVoice => 'Voz';

  @override
  String get advancedSettingQuickSwitcherButtonLabel =>
      'Botão do seletor rápido';

  @override
  String get advancedSettingQuickSwitcherButtonDescription =>
      'Substitui o botão de mensagem de voz na entrada de texto por um seletor rápido para navegação veloz';

  @override
  String get userSettingsCheckForUpdates => 'Verificar atualizações';

  @override
  String get userSettingsCheckingForUpdates => 'Verificando atualizações…';

  @override
  String get userSettingsAppUpToDate => 'O Fluxer está atualizado';

  @override
  String get userSettingsUpdateAvailableTitle => 'Atualização disponível';

  @override
  String get userSettingsUpdateDownloadAction => 'Baixar e instalar';

  @override
  String get userSettingsUpdateInstallAction => 'Instalar atualização';

  @override
  String userSettingsDownloadingUpdate(int percent) {
    return 'Baixando atualização ($percent%)…';
  }

  @override
  String get userSettingsUpdateFailed =>
      'Falha ao verificar ou baixar a atualização.';

  @override
  String get personaSelectTitle => 'Selecionar persona';

  @override
  String get personaSettingsHeader => 'Configurações de personas';

  @override
  String get personaManageAction => 'Gerenciar';

  @override
  String get personaSearchPlaceholder =>
      'Pesquisar personas, tags, pronomes...';

  @override
  String get personaModeManual => 'Manual';

  @override
  String get personaModeLast => 'Usada por último';

  @override
  String get personaModeManualDescription =>
      'Sempre envia como a persona selecionada até que seja alterada.';

  @override
  String get personaModeLastDescription =>
      'Alterna automaticamente para a persona usada na sua última mensagem.';

  @override
  String get personaRecentHeader => 'PERSONAS RECENTES';

  @override
  String personaAllHeader(int count) {
    return 'TODAS AS PERSONAS ($count)';
  }

  @override
  String personaSearchResultsHeader(int count) {
    return 'RESULTADOS DA PESQUISA ($count)';
  }

  @override
  String get personaRootAccountLabel => 'Conta principal (Padrão)';

  @override
  String get personaEmptyState =>
      'Nenhuma persona configurada ainda. Crie uma em Gerenciar personas.';

  @override
  String get personaEmptySearch => 'Nenhuma persona correspondente encontrada.';

  @override
  String get personaEditTitle => 'Editar persona';

  @override
  String get personaCreateTitle => 'Criar persona';

  @override
  String get personaDisplayNameLabel => 'Nome de exibição';

  @override
  String get personaPronounsLabel => 'Pronomes';

  @override
  String get personaPronounsHint => 'ex. ela/dela';

  @override
  String get personaBioHint => 'Conte aos outros sobre essa persona...';

  @override
  String get personaUpdatedToast => 'Persona atualizada';

  @override
  String personaUpdateFailedToast(String error) {
    return 'Falha ao atualizar a persona: $error';
  }

  @override
  String get personaSectionTitle => 'Personas';

  @override
  String get personaDisplayNameHint => 'Nome da persona';

  @override
  String personaSendingAsTag(String name) {
    return 'Enviando como $name (Correspondência por tag)';
  }

  @override
  String personaSendingAsLatched(String name) {
    return 'Enviando como $name (Fixada)';
  }

  @override
  String personaSendingAsRoot(String username) {
    return 'Enviando como @$username';
  }

  @override
  String get personaMainAccount => 'Conta principal';

  @override
  String get personaEditPersona => 'Editar persona';

  @override
  String get userSettingsNavPersonas => 'Personas';

  @override
  String get personaSettingsDescription =>
      'Configure seu modo de persona ativo, sua tag de exibição personalizada e gerencie personas individuais.';

  @override
  String get personaDisplayTagSection => 'Tag de exibição';

  @override
  String get personaDisplayTagDescription =>
      'A tag de exibição aparecerá ao lado do nome de todas as personas nas mensagens. Se nenhuma tag de exibição for definida, a foto de perfil da sua conta será exibida.';

  @override
  String get personaDisplayTagLabel => 'Texto da tag de exibição';

  @override
  String get personaDisplayTagHint => 'ex. SYS';

  @override
  String get personaDisplayTagIconLabel => 'Ícone da tag de exibição';

  @override
  String get personaUploadTagIcon => 'Enviar ícone';

  @override
  String get personaChangeTagIcon => 'Alterar ícone';

  @override
  String get personaRemoveTagIcon => 'Remover ícone';

  @override
  String get personaChatPreviewTitle => 'Prévia do chat';

  @override
  String get personaChatPreviewSampleMessage =>
      'Olá! Esta é uma prévia de como as mensagens aparecem com sua tag de exibição e persona ativa.';

  @override
  String get personaListTitle => 'Personas configuradas';

  @override
  String get personaAddButton => 'Adicionar persona';

  @override
  String get personaActiveBadge => 'Ativo';

  @override
  String get personaMakeActive => 'Tornar ativa';

  @override
  String get personaDeleteTitle => 'Excluir persona';

  @override
  String personaDeleteMessage(String name) {
    return 'Tem certeza de que deseja excluir \"$name\"? Esta ação não poderá ser desfeita.';
  }

  @override
  String get personaDeleteConfirm => 'Excluir';

  @override
  String get personaDeletedToast => 'Persona excluída';

  @override
  String get personaCreatedToast => 'Persona criada';

  @override
  String personaCreateFailedToast(String error) {
    return 'Falha ao criar a persona: $error';
  }

  @override
  String get personaChangeAvatar => 'Alterar avatar';

  @override
  String get personaRemoveAvatar => 'Remover avatar';

  @override
  String get personaUploadAvatar => 'Enviar avatar';

  @override
  String get personaTagsLabel => 'Tags de persona';

  @override
  String get personaTagPrefixLabel => 'Prefixo';

  @override
  String get personaTagSuffixLabel => 'Sufixo';

  @override
  String get personaVisibilityLabel => 'Visibilidade';

  @override
  String get personaVisibilityUnlisted => 'Não listada';

  @override
  String get personaVisibilityPublic => 'Pública';

  @override
  String get personaVisibilityPrivate => 'Privada';

  @override
  String get personaNameRequired =>
      'Por favor, insira um nome de exibição para a persona';

  @override
  String get personaNameTooLong =>
      'O nome de exibição da persona deve ter 100 caracteres ou menos';

  @override
  String get personaTagPrefixTooLong =>
      'O prefixo da tag da persona deve ter 32 caracteres ou menos';

  @override
  String get personaTagSuffixTooLong =>
      'O sufixo da tag da persona deve ter 32 caracteres ou menos';

  @override
  String personaTagCollisionError(String tag, String name) {
    return 'A tag \'$tag\' já está em uso por \'$name\'.';
  }

  @override
  String get chatInsertTimestamp => 'Inserir carimbo de data/hora';

  @override
  String get timestampPickerTitle => 'Inserir carimbo de data/hora';

  @override
  String get timestampPickerInsert => 'Inserir';

  @override
  String get timestampCopied => 'Carimbo de data/hora copiado';

  @override
  String get timestampPickerTimeLabel => 'Hora';

  @override
  String get timestampPickerDateLabel => 'DATA';

  @override
  String get timestampPickerTimeSectionLabel => 'HORA';

  @override
  String get timestampPickerTimezoneLabel => 'FUSO HORÁRIO';

  @override
  String get timestampPickerFormatPreviewLabel => 'PRÉ-VISUALIZAÇÃO DO FORMATO';

  @override
  String get timestampPickerNlpPlaceholder =>
      'ex.: amanhã às 15h, em 2 horas, agora';

  @override
  String get timestampPickerSearchTimezones => 'Pesquisar fusos horários...';

  @override
  String get userProfileTimezoneSettingLabel => 'Fuso horário';

  @override
  String get userProfileTimezoneSettingDescription =>
      'Usado para mostrar sua hora local em seu perfil.';

  @override
  String get userProfileTimezoneNone => 'Nenhum';

  @override
  String get chatReactAs => 'Reagir como...';

  @override
  String get emojiCopy => 'Copiar emoji';

  @override
  String get emojiCopyLink => 'Copiar link';

  @override
  String get personaSignatureEmojisLabel => 'Emojis de assinatura';

  @override
  String get personaSignatureEmojisDescription =>
      'Reagir com um emoji de assinatura sempre reagirá como esta persona, independentemente da persona ativa.';

  @override
  String get personaAddSignatureEmoji => 'Adicionar emoji';

  @override
  String get personaSignatureEmojiAlreadyAdded =>
      'Este emoji já foi adicionado como emoji de assinatura';

  @override
  String personaSignatureEmojiAlreadyUsedByOther(String name) {
    return 'O emoji de assinatura já está em uso pela persona \"$name\"';
  }

  @override
  String get personaRemoveSignatureEmoji => 'Remover emoji de assinatura';

  @override
  String get signalBarLabel => 'Barra de sinais';

  @override
  String get signalBarShow => 'Mostrar barra de sinais';

  @override
  String get signalBarHide => 'Ocultar barra de sinais';

  @override
  String signalBarSignalWithNames(String label, String names) {
    return '$label: $names';
  }

  @override
  String get signalBarNobody => 'Ninguém está com este sinal ligado';

  @override
  String get signalBarReset => 'Redefinir sinal para todos';

  @override
  String signalBarTurnOff(String name) {
    return 'Desligar $name';
  }
}
