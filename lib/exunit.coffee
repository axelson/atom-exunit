ExUnitView = require './exunit-view'
{CompositeDisposable} = require 'atom'
url = require 'url'

module.exports =
  config:
    command:
      type: 'string'
      default: 'mix test'
    spec_directory:
      type: 'string'
      default: 'test'
    save_before_run:
      type: 'boolean'
      default: false
    force_colored_results:
      type: 'boolean'
      default: true

  exUnitView: null
  subscriptions: null

  activate: (state) ->
    if state?
      @lastFile = state.lastFile
      @lastLine = state.lastLine

    @subscriptions = new CompositeDisposable

    @subscriptions.add atom.commands.add 'atom-workspace',
      'exunit:run': =>
        @run()

      'exunit:run-for-line': =>
        @runForLine()

      'exunit:run-last': =>
        @runLast()

      'exunit:run-all': =>
        @runAll()

    atom.workspace.addOpener (uriToOpen) ->
      {protocol, pathname} = url.parse(uriToOpen)
      return unless protocol is 'exunit-output:'
      new ExUnitView(pathname)

  deactivate: ->
    @exUnitView.destroy()
    @subscriptions.dispose()

  serialize: ->
    exUnitViewState: @exUnitView.serialize()
    lastFile: @lastFile
    lastLine: @lastLine

  openUriFor: (file, lineNumber) ->
    @lastFile = file
    @lastLine = lineNumber

    previousActivePane = atom.workspace.getActivePane()
    uri = "exunit-output://#{file}"
    atom.workspace.open(uri, split: 'right', activatePane: false, searchAllPanes: true).done (exUnitView) ->
      if exUnitView instanceof ExUnitView
        exUnitView.run(lineNumber)
        previousActivePane.activate()

  runForLine: ->
    console.log "Starting runForLine..."
    editor = atom.workspace.getActiveTextEditor()
    console.log "Editor", editor
    return unless editor?

    cursor = editor.getLastCursor()
    console.log "Cursor", cursor
    line = cursor.getBufferRow() + 1
    console.log "Line", line

    @openUriFor(editor.getPath(), line)

  runLast: ->
    return unless @lastFile?
    @openUriFor(@lastFile, @lastLine)

  run: ->
    console.log "RUN"
    editor = atom.workspace.getActiveTextEditor()
    return unless editor?

    @openUriFor(editor.getPath())

  runAll: ->
    project = atom.project
    return unless project?

    @openUriFor(project.getPaths()[0] +
    "/" + atom.config.get("exunit.spec_directory"), @lastLine)
