// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'LingoTune';

  @override
  String get library => 'Biblioteca';

  @override
  String get playlists => 'Playlists';

  @override
  String get settings => 'Configurações';

  @override
  String get allSongs => 'Todas as músicas';

  @override
  String get favorites => 'Favoritos';

  @override
  String get createPlaylist => 'Criar playlist';

  @override
  String get playlistName => 'Nome da playlist';

  @override
  String get iconOptional => 'Ícone (opcional)';

  @override
  String get cancel => 'Cancelar';

  @override
  String get create => 'Criar';

  @override
  String get delete => 'Excluir';

  @override
  String get edit => 'Editar';

  @override
  String get save => 'Salvar';

  @override
  String get close => 'Fechar';

  @override
  String get search => 'Pesquisar';

  @override
  String get filter => 'Filtro';

  @override
  String get sort => 'Ordenar';

  @override
  String get addToFavorites => 'Adicionar aos favoritos';

  @override
  String get removeFromFavorites => 'Remover dos favoritos';

  @override
  String get addToPlaylist => 'Adicionar à playlist';

  @override
  String get removeFromPlaylist => 'Remover da playlist';

  @override
  String get addSongsToLibrary => 'Adicionar músicas da biblioteca';

  @override
  String get noSongsToAdd => 'Nenhuma música para adicionar';

  @override
  String addButtonText(Object count) {
    return 'Adicionar $count';
  }

  @override
  String get selected => 'selecionadas';

  @override
  String get darkMode => 'Modo escuro';

  @override
  String get lightMode => 'Modo claro';

  @override
  String get autoScroll => 'Rolagem automática';

  @override
  String get autoScrollSubtitle => 'Rolar automaticamente para a linha atual';

  @override
  String get highlightNextLine => 'Destacar próxima linha';

  @override
  String get highlightNextLineSubtitle => 'Mostrar próxima linha com destaque sutil';

  @override
  String get fontSize => 'Tamanho da fonte';

  @override
  String get scrollOffset => 'Deslocamento de rolagem';

  @override
  String get scrollOffsetSubtitle => 'Distância do topo da tela em pixels';

  @override
  String get autoScrollFocusOffset => 'Deslocamento do foco da rolagem automática';

  @override
  String get autoScrollFocusOffsetSubtitle => 'Posição do foco inicial para a rolagem automática (padrão: +50)';

  @override
  String get defaultTranslationLanguage => 'Idioma de tradução padrão';

  @override
  String get defaultOriginalLanguage => 'Idioma original padrão';

  @override
  String get russian => 'Russo';

  @override
  String get english => 'Inglês';

  @override
  String get romanian => 'Romeno';

  @override
  String get french => 'Francês';

  @override
  String get german => 'Alemão';

  @override
  String get spanish => 'Espanhol';

  @override
  String get italian => 'Italiano';

  @override
  String get portuguese => 'Português';

  @override
  String get lyricsFolder => 'Pasta de letras';

  @override
  String get useLyricsFolder => 'Usar pasta de letras';

  @override
  String get useLyricsFolderDisabled => 'Desativado - os arquivos devem ser selecionados com o áudio';

  @override
  String get setLyricsFolder => 'Definir pasta de letras';

  @override
  String get selectFolder => 'Selecionar pasta';

  @override
  String get folderPath => 'Caminho da pasta';

  @override
  String get examples => 'Exemplos:';

  @override
  String get defaultFolder => 'Padrão: /LingoTune_Lyrics';

  @override
  String get currentFolder => 'Pasta atual:';

  @override
  String folderSetSuccessfully(Object path) {
    return 'Pasta definida: $path';
  }

  @override
  String get folderSetFailed => 'A pasta não existe ou sem acesso';

  @override
  String get resetToDefault => 'Redefinir para padrão';

  @override
  String get showCurrentFolder => 'Mostrar pasta atual';

  @override
  String get changeFolder => 'Alterar pasta';

  @override
  String get resetToDefaultFolder => 'Redefinir para pasta padrão';

  @override
  String get folderReset => 'Pasta redefinida para padrão';

  @override
  String get clearCache => 'Limpar cache';

  @override
  String get clearCacheSubtitle => 'Excluir arquivos temporários';

  @override
  String get cacheCleared => 'Cache limpo';

  @override
  String get resetSongLanguages => 'Redefinir idiomas das músicas';

  @override
  String get resetSongLanguagesSubtitle => 'Usar idioma padrão das configurações';

  @override
  String get songLanguagesReset => 'Idiomas das músicas redefinidos';

  @override
  String get about => 'Sobre';

  @override
  String get translationsLoaded => 'Traduções carregadas com sucesso!';

  @override
  String failedToLoadTranslations(Object error) {
    return 'Falha ao carregar traduções: $error';
  }

  @override
  String get editTranslations => 'Editar traduções';

  @override
  String get loadTranslationsFromFile => 'Carregar traduções do arquivo';

  @override
  String get loadTextMenu => 'Carregar texto';

  @override
  String get loadTranslations => 'Carregar traduções';

  @override
  String get deleteTranslation => 'Excluir tradução';

  @override
  String get noFileSelected => 'Nenhum arquivo selecionado';

  @override
  String get noLrcFileAssociated => 'Nenhum arquivo LRC associado a esta música';

  @override
  String get lrcFileSaved => 'Arquivo LRC salvo com sucesso!';

  @override
  String failedToSaveLrcFile(Object error) {
    return 'Falha ao salvar arquivo LRC: $error';
  }

  @override
  String get exitEditMode => 'Sair do modo de edição';

  @override
  String get editTimestamps => 'Editar timestamps';

  @override
  String get saveChanges => 'Salvar alterações';

  @override
  String get language => 'Idioma';

  @override
  String get loading => 'Carregando...';

  @override
  String get noSongsFound => 'Nenhuma música encontrada';

  @override
  String get noPlaylistsFound => 'Nenhuma playlist encontrada';

  @override
  String get selectSong => 'Selecione uma música para reproduzir';

  @override
  String get song => 'Música';

  @override
  String get artist => 'Artista';

  @override
  String get duration => 'Duração';

  @override
  String get actions => 'Ações';

  @override
  String get play => 'Reproduzir';

  @override
  String get pause => 'Pausar';

  @override
  String get stop => 'Parar';

  @override
  String get previous => 'Anterior';

  @override
  String get next => 'Próximo';

  @override
  String get rewind10 => '-10s';

  @override
  String get forward10 => '+10s';

  @override
  String get repeat => 'Repetir';

  @override
  String get shuffle => 'Aleatório';

  @override
  String get volume => 'Volume';

  @override
  String get speed => 'Velocidade';

  @override
  String get lyrics => 'Letras';

  @override
  String get translations => 'Traduções';

  @override
  String get originalText => 'Texto original';

  @override
  String get translatedText => 'Texto traduzido';

  @override
  String get showTranscription => 'Mostrar transcrição';

  @override
  String get showTranscriptionSubtitle => 'Mostrar guia de pronúncia';

  @override
  String get showTranslationFirst => 'Tradução primeiro';

  @override
  String get showTranslationFirstSubtitle => 'Mostrar tradução antes do texto original';

  @override
  String get italianLang => 'Italiano';

  @override
  String get portugueseLang => 'Português';

  @override
  String get lyricsEditor => 'Editor de letras';

  @override
  String get addLine => 'Adicionar linha';

  @override
  String get updateLine => 'Atualizar linha';

  @override
  String get deleteLine => 'Excluir linha';

  @override
  String get clearAll => 'Limpar tudo';

  @override
  String get moveUp => 'Para cima';

  @override
  String get moveDown => 'Para baixo';

  @override
  String get autoSyncLyrics => 'Sincronização automática de letras';

  @override
  String get exportLrc => 'Exportar LRC (Original)';

  @override
  String get exportJson => 'Exportar JSON (Traduções)';

  @override
  String get markTimestamp => 'Marcar timestamp (Enter)';

  @override
  String get original => 'Original';

  @override
  String get translation => 'Tradução';

  @override
  String get audioFile => 'Arquivo de áudio';

  @override
  String get songTitle => 'Título da música';

  @override
  String get browse => 'Procurar';

  @override
  String get audioControls => 'Controles de áudio';

  @override
  String get addEditLine => 'Adicionar/Editar linha';

  @override
  String get instructions => 'Instruções';

  @override
  String get lyricsEditorInstructions => 'Instruções de sincronização LRC:\n\n1. Selecione um arquivo de áudio usando o botão Procurar\n2. Insira o título da música e artista (opcional)\n3. Clique em Reproduzir para iniciar o áudio\n4. Quando uma linha é cantada, digite o texto original no campo \'Original\'\n5. Pressione Enter ou \'Marcar timestamp\' para gravar o timestamp\n6. Opcionalmente adicione uma tradução no campo \'Tradução\'\n7. Repita os passos 4-6 para cada linha\n8. Use \'Exportar LRC\' para salvar o texto original com timestamps\n9. Use \'Exportar JSON\' para salvar as traduções\n\nDicas:\n- Use -10s/+10s para navegar rapidamente pela música\n- Você pode reordenar linhas usando Para cima/Para baixo\n- Carregue arquivos JSON salvos anteriormente para editar traduções';

  @override
  String get welcome => 'Bem-vindo';

  @override
  String get welcomeMessage => 'Comece sua jornada de aprendizado de idiomas com música!';

  @override
  String get importSongs => 'Importar músicas';

  @override
  String get importSongsSubtitle => 'Adicionar arquivos de áudio do seu dispositivo';

  @override
  String get manageLibrary => 'Gerenciar biblioteca';

  @override
  String get manageLibrarySubtitle => 'Organize suas músicas e playlists';

  @override
  String get syncLyrics => 'Sincronizar letras';

  @override
  String get syncLyricsSubtitle => 'Sincronização automática de letras com áudio';

  @override
  String get languageLearning => 'Aprendizado de idiomas • Música • Traduções';

  @override
  String get version => 'Versão';

  @override
  String get developer => 'Desenvolvido por';

  @override
  String get website => 'Site';

  @override
  String failedToCreatePlaylist(Object error) {
    return 'Falha ao criar playlist: $error';
  }

  @override
  String get playlistCreated => 'Playlist criada com sucesso!';

  @override
  String get playlistDeleted => 'Playlist excluída com sucesso!';

  @override
  String get playlistUpdated => 'Playlist atualizada com sucesso!';

  @override
  String get songAdded => 'Música adicionada com sucesso!';

  @override
  String get songRemoved => 'Música removida com sucesso!';

  @override
  String get songDeleted => 'Música excluída com sucesso!';

  @override
  String get error => 'Erro';

  @override
  String get warning => 'Aviso';

  @override
  String get info => 'Informação';

  @override
  String get success => 'Sucesso';

  @override
  String get confirm => 'Confirmar';

  @override
  String get areYouSure => 'Tem certeza?';

  @override
  String get unsavedChanges => 'Você tem alterações não salvas. Continuar?';

  @override
  String get selectLanguage => 'Selecionar idioma';

  @override
  String get appLanguage => 'Idioma do aplicativo';

  @override
  String get englishLang => 'English';

  @override
  String get russianLang => 'Русский';

  @override
  String get romanianLang => 'Română';

  @override
  String get frenchLang => 'Français';

  @override
  String get germanLang => 'Deutsch';

  @override
  String get spanishLang => 'Español';

  @override
  String get chineseLang => '中文';

  @override
  String get arabicLang => 'العربية';

  @override
  String get welcomeToLingoTune => 'Bem-vindo ao LingoTune';

  @override
  String get folderSetupMessage => 'Escolha uma pasta para armazenar letras e traduções (arquivos LRC e JSON). Isso facilita organizar sua biblioteca de música.';

  @override
  String get selectFolderNow => 'Selecionar pasta agora';

  @override
  String get goToSettings => 'Ir para configurações';

  @override
  String get setupLater => 'Configurar mais tarde';

  @override
  String get useDefaultFolder => 'Usar pasta padrão';

  @override
  String get databaseFound => 'Banco de dados encontrado no arquivo de importação';

  @override
  String get importDatabaseQuestion => 'Deseja importar também o banco de dados?';

  @override
  String get mergeDatabase => 'Mesclar';

  @override
  String get replaceDatabase => 'Substituir';

  @override
  String get importDatabase => 'Importar banco de dados';

  @override
  String get skipDatabase => 'Pular banco de dados';

  @override
  String get mergeDatabaseDescription => 'Mesclar músicas importadas com sua biblioteca (adiciona apenas novos itens)';

  @override
  String get replaceDatabaseDescription => 'Substituir toda sua biblioteca pelo banco de dados importado (você perderá todos os dados existentes)';

  @override
  String get exporting => 'Exportando...';

  @override
  String exportingProgress(Object current, Object total) {
    return 'Exportando $current de $total músicas';
  }

  @override
  String get exportDatabaseIncluded => 'Banco de dados incluído na exportação';

  @override
  String importSuccessWithDatabase(Object fileCount) {
    return 'Importado(s) $fileCount arquivo(s) e banco de dados';
  }

  @override
  String importSuccessNoDatabase(Object fileCount) {
    return 'Importado(s) $fileCount arquivo(s)';
  }

  @override
  String get chinese => 'Chinês';

  @override
  String get arabic => 'Árabe';

  @override
  String get colorTheme => 'Tema de cor';

  @override
  String get themeColorPurple => 'Roxo';

  @override
  String get themeColorBlue => 'Azul';

  @override
  String get themeColorGreen => 'Verde';

  @override
  String get themeColorOrange => 'Laranja';

  @override
  String get themeColorRed => 'Vermelho';

  @override
  String get themeColorPink => 'Rosa';

  @override
  String get themeColorDeepOrange => 'Laranja escuro';

  @override
  String get themeColorDarkRed => 'Vermelho escuro';

  @override
  String get themeColorTeal => 'Verde-azulado';

  @override
  String get themeColorCyan => 'Ciano';

  @override
  String get themeColorAmber => 'Âmbar';

  @override
  String get themeColorLime => 'Lima';

  @override
  String get ukrainianLang => 'Ucraniano';

  @override
  String get font => 'Fonte';

  @override
  String get fontSettings => 'Configurações de fonte';

  @override
  String get systemFont => 'Sistema';

  @override
  String get fontRoboto => 'Roboto';

  @override
  String get fontOpenSans => 'Open Sans';

  @override
  String get fontLato => 'Lato';

  @override
  String get mainTextSize => 'Tamanho do texto principal';

  @override
  String get mainTextBold => 'Texto principal em negrito';

  @override
  String get translationSize => 'Tamanho da tradução';

  @override
  String get translationBold => 'Tradução em negrito';

  @override
  String get transcriptSize => 'Tamanho da transcrição';

  @override
  String get transcriptBold => 'Transcrição em negrito';

  @override
  String get defaultStartScreen => 'Tela inicial padrão';

  @override
  String get defaultStartScreenSubtitle => 'Tela a ser mostrada ao iniciar o aplicativo';

  @override
  String get addToLibraryWhenAddingToPlaylist => 'Adicionar à biblioteca ao adicionar a uma playlist';

  @override
  String get addToLibraryWhenAddingToPlaylistSubtitle => 'Adicionar automaticamente músicas à biblioteca ao adicioná-las a uma playlist';

  @override
  String get serviceMessages => 'Mensagens de serviço';

  @override
  String get serviceMessagesSubtitle => 'Mostrar notificações de serviço sobre tradução e transcrição';

  @override
  String get includeMp3Files => 'Incluir arquivos MP3';

  @override
  String get includeMp3FilesSubtitle => 'Isso aumentará o tamanho do arquivo';

  @override
  String get importMp3Files => 'Importar arquivos MP3';

  @override
  String get importMp3FilesSubtitle => 'Adicionar arquivos de música à biblioteca';

  @override
  String get exportSongs => 'Exportar músicas';

  @override
  String get import => 'Importar';

  @override
  String get addMultiple => 'Selecionar múltiplos';

  @override
  String get addToPlaylistShort => 'Adicionar';

  @override
  String get deleteShort => 'Excluir';

  @override
  String get selectAllShort => 'Todos';

  @override
  String get deselectAllShort => 'Limpar';

  @override
  String get exitSelectionMode => 'Sair do modo de seleção';

  @override
  String get selectAll => 'Selecionar tudo';

  @override
  String get deselectAll => 'Desmarcar tudo';

  @override
  String get deleteSelected => 'Excluir selecionados';

  @override
  String get addMultipleToPlaylist => 'Adicionar à playlist';

  @override
  String get coverArt => 'Capa';

  @override
  String get playlistCover => 'Capa da playlist';

  @override
  String get selectFromGallery => 'Selecionar da galeria';

  @override
  String get removeCover => 'Remover capa';

  @override
  String get coverUpdated => 'Capa atualizada';

  @override
  String get coverRemoved => 'Capa removida';

  @override
  String errorWithMessage(Object error) {
    return 'Erro: $error';
  }

  @override
  String get importFolders => 'Importar pastas';

  @override
  String get selectMusicFolder => 'Selecionar pasta de música';

  @override
  String get folderWithAudioFiles => 'Pasta com arquivos MP3/WAV';

  @override
  String get sameFolderForLyrics => 'Mesma pasta para letras';

  @override
  String get selectLyricsFolder => 'Selecionar pasta de letras';

  @override
  String get folderWithLyricsFiles => 'Pasta com arquivos LRC/JSON (opcional)';

  @override
  String get pleaseEnterPlaylistName => 'Por favor, digite o nome da playlist';

  @override
  String get pleaseSelectMusicFolder => 'Por favor, selecione uma pasta de música';

  @override
  String get cropImage => 'Recortar imagem';

  @override
  String get photoPermissionRequired => 'Permissão de acesso a fotos necessária';

  @override
  String get photoPermissionDenied => 'Acesso a fotos negado';

  @override
  String get imageProcessingError => 'Falha ao processar imagem';

  @override
  String get scanningFolder => 'Varrendo pasta...';

  @override
  String get importingFiles => 'Importando arquivos...';

  @override
  String importingFolderProgress(Object current, Object songs, Object total) {
    return 'Importando $current/$total arquivos... $songs músicas encontradas';
  }

  @override
  String processingFile(Object file) {
    return 'Processando $file...';
  }

  @override
  String get addToPlaylistDialogTitle => 'Adicionar à playlist';

  @override
  String addedToPlaylist(Object playlist) {
    return 'Adicionado a \"$playlist\"';
  }

  @override
  String failedToAddToPlaylist(Object error) {
    return 'Falha ao adicionar à playlist: $error';
  }

  @override
  String get deleteSong => 'Excluir';

  @override
  String get importSongDialogTitle => 'Importar música';

  @override
  String get audioOnly => 'Apenas áudio';

  @override
  String get addLyricsLater => 'Adicionarei as letras mais tarde';

  @override
  String get audioWithLyricsZIP => 'Áudio + ZIP com letras';

  @override
  String get importWithAllTranslations => 'Importar com todas as traduções';

  @override
  String get importTranslationDialogTitle => 'Adicionar tradução';

  @override
  String get loadTranslationFromZip => 'Carregar de arquivo ZIP';

  @override
  String get loadTranslationFromJson => 'Carregar de arquivo JSON';

  @override
  String get noAudioFilesSelected => 'Nenhum arquivo de áudio selecionado';

  @override
  String failedToImportSongs(Object error) {
    return 'Falha ao importar músicas: $error';
  }

  @override
  String failedToImportSong(Object error) {
    return 'Falha ao importar música: $error';
  }

  @override
  String get musicFolderNotSelected => 'Pasta de música não selecionada';

  @override
  String get generateLyrics => 'Gerar letras';

  @override
  String get selectTextFileOrEnterText => 'Selecionar arquivo texto ou inserir texto';

  @override
  String get originalLanguage => 'Idioma original';

  @override
  String get translationLanguages => 'Idiomas tradução';

  @override
  String get startMinuteForTimestamps => 'Minuto inicial timestamps';

  @override
  String get transcriptionLanguage => 'Idioma transcrição';

  @override
  String get generating => 'Gerando...';

  @override
  String get generate => 'Gerar';

  @override
  String get deepseekApiKey => 'Chave API DeepSeek';

  @override
  String get validateKey => 'Validar chave';

  @override
  String get keyIsValid => 'Chave válida';

  @override
  String get keyIsInvalid => 'Chave inválida';

  @override
  String get lyricsGenerationSuccess => 'Letras geradas com sucesso';

  @override
  String get lyricsGenerationError => 'Falha gerar letras';

  @override
  String get savingFiles => 'Salvando arquivos...';

  @override
  String get enterText => 'Inserir texto';

  @override
  String get transcript => 'Transcrição';

  @override
  String get originalTextEditable => 'Texto original (editável)';

  @override
  String get selectLanguageToEdit => 'Selecionar idioma para editar';

  @override
  String get moveLineUp => 'Mover linha para cima';

  @override
  String get moveLineDown => 'Mover linha para baixo';

  @override
  String get moveAllTranslationsUp => 'Mover todas as traduções para cima';

  @override
  String get moveAllTranslationsDown => 'Mover todas as traduções para baixo';

  @override
  String get translationSaved => 'Tradução salva!';

  @override
  String get translationSaveFailed => 'Falha ao salvar tradução';

  @override
  String get loadTextTitle => 'Carregar texto';

  @override
  String get noOriginalTextWarning => 'Carregue primeiro o texto original';

  @override
  String get selectLanguageOriginal => 'Idioma original';

  @override
  String get startTimestampMinutes => 'Início do timestamp (minutos)';

  @override
  String get selectLanguageTranslation => 'Idioma de tradução';

  @override
  String get originalTextLoaded => 'Texto original carregado com sucesso!';

  @override
  String get translationLoaded => 'Tradução carregada com sucesso!';

  @override
  String get transcriptLoaded => 'Transcrição carregada com sucesso!';

  @override
  String get selectTranslationLanguage => 'Idioma de tradução para transcrição';

  @override
  String get noTranslationWarning => 'Nenhuma tradução carregada';

  @override
  String linesMismatchError(Object expected, Object loaded) {
    return 'Discrepância de linhas: $loaded linhas, esperado $expected';
  }

  @override
  String get loadTextTooltip => 'Carregar texto ou tradução';

  @override
  String get loadFromFile => 'Carregar de arquivo';

  @override
  String get pasteFromClipboard => 'Colar da área de transferência';

  @override
  String get audioNotificationService => 'Serviço de notificação de áudio';

  @override
  String get audioNotificationServiceActive => 'Estado: ✅ Ativo';

  @override
  String get audioNotificationServiceError => 'Estado: ✅ Erro';

  @override
  String get errorLabel => 'Erro:';

  @override
  String get audioNotificationServiceDescription => 'Este serviço fornece notificações quando o aplicativo é minimizado';

  @override
  String get reorder => 'Reordenar';

  @override
  String get done => 'Pronto';

  @override
  String get selectMultiple => 'Selecionar múltiplos';

  @override
  String get sortSongs => 'Ordenar músicas';

  @override
  String get importSong => 'Importar música';

  @override
  String get sortDefault => 'Padrão';

  @override
  String get sortAlphabeticalAsc => 'A-Z';

  @override
  String get sortAlphabeticalDesc => 'Z-A';

  @override
  String get sortDateDesc => 'Mais recentes';

  @override
  String get sortDateAsc => 'Mais antigas';

  @override
  String get importingSongs => 'Importando músicas...';

  @override
  String get noSongsInPlaylist => 'Nenhuma música nesta playlist';

  @override
  String get addSongsFromLibraryHint => 'Adicione músicas da sua biblioteca';

  @override
  String get removedSongsFromPlaylist => 'Músicas removidas da playlist';

  @override
  String failedToRemoveSongs(Object error) {
    return 'Erro ao excluir músicas: $error';
  }

  @override
  String get deletePlaylistTitle => 'Excluir playlist';

  @override
  String deletePlaylistConfirm(Object playlist) {
    return 'Tem certeza de excluir \"$playlist\"?';
  }

  @override
  String get failedToDeletePlaylist => 'Falha ao excluir playlist:';

  @override
  String get specifyTranslationLanguage => 'Especificar idioma da tradução';

  @override
  String get languageNameLabel => 'Nome do idioma';

  @override
  String get languageNameHint => 'Por exemplo: Russo, Do autor, Poético';

  @override
  String get translationTypeLabel => 'Tipo de tradução:';

  @override
  String get translationTypeNormal => 'Normal';

  @override
  String get translationTypeAuthor => 'Do autor';

  @override
  String get translationTypePoetic => 'Poético';

  @override
  String get translationTypeLiteral => 'Literal';

  @override
  String mp3FilesCount(Object count) {
    return 'Arquivos MP3: $count';
  }

  @override
  String importedFilesWithSkippedDatabase(Object count) {
    return '$count arquivo(s) importado(s) (banco de dados ignorado)';
  }

  @override
  String get databaseMerged => 'Banco de dados mesclado';

  @override
  String databaseMergedWithMp3(Object count) {
    return 'Banco de dados mesclado, arquivos MP3: $count';
  }

  @override
  String get databaseReplaced => 'Banco de dados substituído';

  @override
  String databaseReplacedWithMp3(Object count) {
    return 'Banco de dados substituído, arquivos MP3: $count';
  }

  @override
  String get confirmReplaceDatabase => 'Confirmar substituição';

  @override
  String get confirmReplaceDatabaseWarning => 'Tem certeza? Você perderá todas as músicas e playlists existentes!';

  @override
  String get replaceAll => 'Substituir tudo';

  @override
  String get selectLanguages => 'Selecionar idiomas';

  @override
  String selectedLanguagesCount(Object count) {
    return 'Selecionados: $count idiomas';
  }

  @override
  String selectedSongsCount(Object count) {
    return 'Selecionados: $count';
  }

  @override
  String get promptPreset => 'Predefinição de prompt';

  @override
  String get balanced => 'Equilibrado';

  @override
  String get poetic => 'Poético';

  @override
  String get literal => 'Literal';

  @override
  String get customPromptOption => 'Personalizado...';

  @override
  String get editPrompt => 'Editar prompt';

  @override
  String get notSet => 'Não definido';

  @override
  String get showOrEditApiKey => 'Mostrar/Editar chave API';

  @override
  String get timeout => 'Tempo limite';

  @override
  String get model => 'Modelo';

  @override
  String get resetToPreset => 'Redefinir para predefinição';

  @override
  String get customPrompt => 'Prompt personalizado';

  @override
  String customPromptChars(Object count) {
    return 'Prompt personalizado ($count caracteres)';
  }

  @override
  String usingPreset(Object preset) {
    return 'Usando predefinição: $preset';
  }

  @override
  String get characters => 'caracteres';

  @override
  String get deepSeekPromptTitle => 'Prompt DeepSeek';

  @override
  String get customPromptLabel => 'Prompt personalizado';

  @override
  String get leaveEmptyToUseDefault => 'Deixe vazio para usar o prompt padrão';

  @override
  String get leaveEmptyToUseDefaultPrompt => 'Deixe vazio para usar o prompt padrão integrado no aplicativo';

  @override
  String get apiKeySaved => 'Chave API salva';

  @override
  String get enterTimeout => 'Insira o tempo limite em segundos';

  @override
  String get validTimeoutRange => 'Por favor, insira um tempo limite válido (1-3600 segundos)';

  @override
  String get customTimeout => 'Tempo limite personalizado';

  @override
  String get timeoutSeconds => 'Tempo limite (segundos)';

  @override
  String timeoutSetTo(Object value) {
    return 'Tempo limite definido para $value segundos';
  }

  @override
  String get customModel => 'Modelo personalizado';

  @override
  String get modelName => 'Nome do modelo';

  @override
  String get enterModelName => 'Insira o nome exato do modelo fornecido pela DeepSeek API';

  @override
  String get pleaseEnterModelName => 'Por favor, insira um nome de modelo';

  @override
  String modelSetTo(Object value) {
    return 'Modelo definido como $value';
  }

  @override
  String get editCustomPrompt => 'Editar prompt personalizado';

  @override
  String get editPresetPrompt => 'Editar prompt predefinido';

  @override
  String get editingPreset => 'Editando predefinição';

  @override
  String get anyChangesSaveAsCustom => 'Quaisquer alterações serão salvas como prompt personalizado. Use o botão \'Redefinir\' para restaurar a predefinição original.';

  @override
  String get useResetToRestorePreset => 'Use o botão \'Redefinir\' para restaurar a predefinição original';

  @override
  String get prompt => 'Prompt';

  @override
  String get promptSaved => 'Prompt salvo';

  @override
  String get usingPresetPrompt => 'Usando prompt predefinido';

  @override
  String get apiKeyHint => 'Chave API';

  @override
  String get modelHint => 'ex. deepseek-v3';

  @override
  String get enterExactModelName => 'Insira o nome exato do modelo fornecido pela DeepSeek API.';

  @override
  String get pleaseEnterApiKeyFirst => 'Por favor, insira a chave API primeiro';

  @override
  String get maxTokensRegular => 'Max Tokens (Normal)';

  @override
  String get maxTokensJson => 'Max Tokens (JSON)';

  @override
  String get maxTokensRegularHint => 'Limite de tokens para solicitações de tradução normais';

  @override
  String get maxTokensJsonHint => 'Limite de tokens para solicitações de geração completa (JSON)';

  @override
  String maxTokensRegularSetTo(Object value) {
    return 'Max tokens (normal) definido para $value';
  }

  @override
  String maxTokensJsonSetTo(Object value) {
    return 'Max tokens (JSON) definido para $value';
  }

  @override
  String get refreshFolder => 'Atualizar pasta';

  @override
  String get refreshingFolder => 'Atualizando pasta...';

  @override
  String get playlistCreatedWithLink => 'Playlist criada! Pressione \"Atualizar\" para carregar músicas da pasta';

  @override
  String refreshedPlaylist(Object count) {
    return 'Atualizado: $count músicas';
  }

  @override
  String refreshPlaylistError(Object error) {
    return 'Erro de atualização: $error';
  }

  @override
  String failedToLoadSongs(Object error) {
    return 'Erro ao carregar músicas: $error';
  }

  @override
  String get musicFolderDoesNotExist => 'Pasta de música não existe';

  @override
  String successfullyImportedSongs(Object count) {
    return 'Importadas com sucesso $count música(s)';
  }

  @override
  String get noAudioFileSelected => 'Nenhum arquivo de áudio selecionado';

  @override
  String get noZipArchiveSelected => 'Nenhum arquivo ZIP selecionado';

  @override
  String get noFolderConfigured => 'Pasta não configurada';

  @override
  String get missingLyricsTranslations => 'Letras/Traduções ausentes';

  @override
  String missingForSong(Object songName) {
    return 'Para \"$songName\"';
  }

  @override
  String missingFilesList(Object files) {
    return 'Ausentes: $files';
  }

  @override
  String get whatWouldYouLikeToDo => 'O que você gostaria de fazer?';

  @override
  String get lyricsGeneratedSuccessfully => 'Letras geradas com sucesso';

  @override
  String get setDeepSeekApiKey => 'Por favor configure a chave API DeepSeek nas configurações';

  @override
  String failedToOpenSong(Object error) {
    return 'Erro ao abrir música: $error';
  }

  @override
  String get alsoDeleteLrcJsonFiles => 'Também excluir arquivos LRC e JSON';

  @override
  String addedToPlaylistWithQuotes(Object playlist) {
    return 'Adicionado a \"$playlist\"';
  }

  @override
  String failedToAddToPlaylistError(Object error) {
    return 'Erro ao adicionar à playlist: $error';
  }

  @override
  String exportedSongsCount(Object count) {
    return '$count música(s) exportada(s)';
  }

  @override
  String get fileNotFound => 'Arquivo não encontrado';

  @override
  String get selectZipFileNotJson => 'Por favor selecione um arquivo ZIP, não JSON ou LRC';

  @override
  String get noFilesFoundInZip => 'Nenhum arquivo encontrado no ZIP';

  @override
  String invalidZipFileFormat(Object error) {
    return 'Formato de arquivo ZIP inválido: $error';
  }

  @override
  String importFailed(Object error) {
    return 'Erro ao importar: $error';
  }

  @override
  String foundTranslationsCount(Object count) {
    return '$count tradução/ões encontrada(s)';
  }

  @override
  String mp3ImportError(Object error) {
    return 'Erro de importação MP3: $error';
  }

  @override
  String get importSongFirstToSearch => 'Importe uma música primeiro para procurar letras';

  @override
  String get lyricsFetched => 'Letras recuperadas';

  @override
  String get lyricsFoundUseCreate => 'Letras encontradas. Use para criar um arquivo LRC sincronizado';

  @override
  String get deleteSelectedSongs => 'Excluir músicas selecionadas';

  @override
  String deleteMultipleSongsConfirm(Object count) {
    return 'Tem certeza que deseja excluir $count música(s)?';
  }

  @override
  String get songsDeletedSuccessfully => 'Músicas excluídas com sucesso';

  @override
  String get storagePermissionRequired => 'Permissão de armazenamento necessária para acessar pastas.';

  @override
  String get enableStoragePermission => 'Por favor habilite a permissão de armazenamento nas configurações.';

  @override
  String get openSettings => 'Abrir configurações';

  @override
  String get unableToSelectFolder => 'Não foi possível selecionar pasta. Tente alternativa:';

  @override
  String get selectFilesInstead => 'Selecionar arquivos em vez disso';

  @override
  String get enterFolderPath => 'Por favor entre com um caminho de pasta';

  @override
  String get folderDoesNotExist => '✗ A pasta não existe';

  @override
  String folderSetWithPath(Object path) {
    return 'Pasta definida: $path';
  }

  @override
  String errorSettingFolder(Object error) {
    return 'Erro ao definir pasta: $error';
  }

  @override
  String get unableToSelectLyricsFolder => 'Não foi possível selecionar pasta de letras. Tente alternativa:';

  @override
  String get useManualPath => 'Usar caminho manual (para testes)';

  @override
  String get enterFolderPathManually => 'Digite o caminho da pasta manualmente em vez de usar o seletor';

  @override
  String get folderPathLabel => 'Caminho da pasta';

  @override
  String get folderPathHint => 'Exemplo: /storage/emulated/0/Music';

  @override
  String get fullPathToMusicFolder => 'Caminho completo para sua pasta de música';

  @override
  String get setPath => 'Definir caminho';

  @override
  String selectZipArchiveWithLyrics(Object title) {
    return 'Selecionar arquivo ZIP com letras para \"$title\"';
  }

  @override
  String get skip => 'Pular';

  @override
  String get retry => 'Tentar novamente';

  @override
  String get failedToCopyLrcFile => 'Erro ao copiar arquivo LRC';

  @override
  String copiedJsonFiles(Object count) {
    return '$count arquivo(s) JSON copiado(s)';
  }

  @override
  String get failedToCopyJsonFiles => 'Erro ao copiar arquivos JSON';

  @override
  String failedToDeleteSong(Object error) {
    return 'Erro ao excluir música: $error';
  }

  @override
  String addedMultipleSongsToPlaylist(Object count, Object playlist) {
    return '$count música(s) adicionada(s) a \"$playlist\"';
  }

  @override
  String addMultipleSongsToPlaylistTitle(Object count) {
    return 'Adicionar $count música(s) à playlist';
  }

  @override
  String get failedToExportSongs => 'Erro ao exportar músicas';

  @override
  String get ok => 'OK';

  @override
  String deleteSongConfirm(Object song) {
    return 'Tem certeza que deseja excluir \"$song\"?';
  }

  @override
  String get selectMusicFolderForPlaylist => 'Selecionar pasta de música para esta playlist';

  @override
  String get folderLinkedToPlaylist => 'Pasta vinculada à playlist';

  @override
  String get folderUnlinkedFromPlaylist => 'Pasta desvinculada da playlist';

  @override
  String get checkFolderAccess => 'Verificar acesso';

  @override
  String get checkingPermissions => 'Verificando permissões...';

  @override
  String get folderAccessible => '✓ Pasta acessível';

  @override
  String get folderNotAccessible => '✗ Pasta inacessível';

  @override
  String audioFilesFound(Object count) {
    return '$count arquivo(s) de áudio encontrado(s)';
  }

  @override
  String lyricsFound(Object count) {
    return '$count arquivo(s) de letras encontrado(s)';
  }

  @override
  String get noAudioFiles => 'Nenhum arquivo de áudio encontrado';

  @override
  String get noLyricsFiles => 'Nenhum arquivo de letras encontrado';

  @override
  String errorCheckingAccess(Object error) {
    return 'Erro ao verificar acesso: $error';
  }

  @override
  String get folderPathColon => 'Caminho da pasta:';

  @override
  String get permissionsStatus => 'Status das permissões:';

  @override
  String get folderContent => 'Conteúdo da pasta:';

  @override
  String get accessGranted => '✓ Acesso concedido';

  @override
  String get accessDenied => '✗ Acesso negado';

  @override
  String get permissionRequestFailed => 'Falha ao solicitar permissões';

  @override
  String get pleaseGrantPermissions => 'Conceda permissões de armazenamento para verificar a pasta';

  @override
  String get refreshOnlySongs => 'Apenas músicas';

  @override
  String get refreshEverything => 'Tudo';

  @override
  String get refreshDialogDescription => 'O que você gostaria de atualizar? \"Apenas músicas\" acelera o processo pulando letras.';

  @override
  String get mostSongs => 'Mais músicas';
}
