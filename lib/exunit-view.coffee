{$, $$$, EditorView, ScrollView} = require 'atom-space-pen-views'
path = require 'path'
ChildProcess  = require 'child_process'
TextFormatter = require './text-formatter'

class ExUnitView extends ScrollView
  atom.deserializers.add(this)

  @deserialize: ({filePath}) ->
    new ExUnitView(filePath)

  @content: ->
    @div class: 'exunit exunit-console', tabindex: -1, =>
      @div class: 'exunit-spinner', 'Starting ExUnit...'
      @pre class: 'exunit-output'

  initialize: ->
    super
    @on 'core:copy': => @copySelectedText()

  constructor: (filePath) ->
    super
    console.log "File path:", filePath
    @filePath = filePath

    @output  = @find(".exunit-output")
    @spinner = @find(".exunit-spinner")
    @output.on("click", @terminalClicked)

  serialize: ->
    deserializer: 'ExUnitView'
    filePath: @getPath()

  copySelectedText: ->
    text = window.getSelection().toString()
    return if text == ''
    atom.clipboard.write(text)

  getTitle: ->
    "ExUnit - #{path.basename(@getPath())}"

  getURI: ->
    "exunit-output://#{@getPath()}"

  getPath: ->
    @filePath

  showError: (result) ->
    failureMessage = "The error message"

    @html $$$ ->
      @h2 'Running ExUnit Failed'
      @h3 failureMessage if failureMessage?

  terminalClicked: (e) =>
    if e.target?.href
      line = $(e.target).data('line')
      file = $(e.target).data('file')
      console.log(file)
      file = "#{atom.project.getPaths()[0]}/#{file}"

      promise = atom.workspace.open(file, { searchAllPanes: true, initialLine: line })
      promise.done (editor) ->
        editor.setCursorBufferPosition([line-1, 0])

  run: (lineNumber) ->
    atom.workspace.saveAll() if atom.config.get("exunit.save_before_run")
    @spinner.show()
    @output.empty()
    projectPath = atom.project.getPaths()[0]
    rootDirectory = atom.config.get("exunit.root_directory")

    spawn = ChildProcess.spawn

    # Atom saves config based on package name, so we need to use exunit here.
    specCommand = atom.config.get("exunit.command")
    options = ""
    # options = " --tty"
    # options += " --color" if atom.config.get("exunit.force_colored_results")
    command = "#{specCommand} #{options} #{@filePath}"
    command = "#{command}:#{lineNumber}" if lineNumber

    console.log "[ExUnit] running: #{command}"
    @addOutput "[ExUnit] running: #{command}\n"
    @addOutput "root directory: #{rootDirectory}" if rootDirectory && rootDirectory != ''
    @addOutput "\n\n"

    terminal = spawn("bash", ["-l"])

    terminal.on 'close', @onClose

    terminal.stdout.on 'data', @onStdOut
    terminal.stderr.on 'data', @onStdErr

    terminal.stdin.write("cd #{projectPath}/#{rootDirectory} && #{command}\n")
    terminal.stdin.write("exit\n")

  addOutput: (output) =>
    formatter = new TextFormatter(output)
    output = formatter.htmlEscaped().colorized().fileLinked().text

    @spinner.hide()
    @output.append("#{output}")
    @scrollTop(@[0].scrollHeight)

  onStdOut: (data) =>
    @addOutput data

  onStdErr: (data) =>
    @addOutput data

  onClose: (code) =>
    console.log "[ExUnit] exit with code: #{code}"

module.exports = ExUnitView
