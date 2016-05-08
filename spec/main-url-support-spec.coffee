clipboard = require 'clipboard'
temp = require('temp').track()
path = require 'path'
fs = require 'fs'
asciiDocimageHelper = require '../lib/main'
fakeAsciiDocGrammarBuilder = require './fixtures/fake-asciidoc-grammar-builder'

describe 'URL with AsciiDoc Image helper should', ->

  imageName = 'logo-atom.png'
  [directory, editor, workspaceElement] = []

  beforeEach ->
    directory = temp.mkdirSync()
    atom.project.setPaths [directory]
    workspaceElement = atom.views.getView atom.workspace
    filePath = path.join directory, 'foobar.adoc'
    fs.writeFileSync filePath, 'foobar'

    waitsForPromise ->
      atom.packages.activatePackage 'asciidoc-image-helper'

    waitsForPromise ->
      Promise.resolve()
        .then -> atom.workspace.open(filePath)
        .then (ed) -> editor = ed
        .then (ed) -> fakeAsciiDocGrammarBuilder.createGrammar()
        .then (grammar) ->  editor.setGrammar(grammar)

  afterEach ->
    clipboard.clear()
    editor?.destroy()
    temp.cleanupSync()


  it 'create a link and store the image in a directory when image folder append to link and URL in "windows style" and use the default directory', ->
    called = false
    asciiDocimageHelper.onDidInsert -> called = true

    atom.config.set 'asciidoc-image-helper.appendImagesFolder', true # Default
    atom.config.set 'asciidoc-image-helper.enableUrlSupport', true

    editor = atom.workspace.getActiveTextEditor()
    expect(editor.getPath()).toMatch /^.*(\/|\\)foobar\.adoc$/

    editor.selectAll()
    expect(editor.getSelectedText()).toMatch /^foobar$/
    editor.delete()

    imageUrl = '"file:///' + path.join(__dirname, 'fixtures', imageName) + '"'
    clipboard.writeText imageUrl
    atom.commands.dispatch workspaceElement, 'core:paste'

    waitsFor 'markup insertion', -> called is true

    runs ->
      editor.selectAll()
      expect(editor.getSelectedText()).toMatch /image::images(\/|\\)logo-atom\.png\[\]/
      imagesFolder = atom.config.get 'asciidoc-image-helper.imagesFolder'
      stat = fs.statSync path.join directory, imagesFolder, imageName
      expect(stat).toBeDefined()
      expect(stat.size).toBe 6258


  it 'create a link and store the image in a directory when image folder append to link and use the default directory', ->
    called = false
    asciiDocimageHelper.onDidInsert -> called = true

    atom.config.set 'asciidoc-image-helper.appendImagesFolder', true # Default
    atom.config.set 'asciidoc-image-helper.enableUrlSupport', true

    editor = atom.workspace.getActiveTextEditor()
    expect(editor.getPath()).toMatch /^.*(\/|\\)foobar\.adoc$/

    editor.selectAll()
    expect(editor.getSelectedText()).toMatch /^foobar$/
    editor.delete()

    imageUrl = path.join __dirname, 'fixtures', imageName
    clipboard.writeText imageUrl
    atom.commands.dispatch workspaceElement, 'core:paste'

    waitsFor 'markup insertion', -> called is true

    runs ->
      editor.selectAll()
      expect(editor.getSelectedText()).toMatch /image::images(\/|\\)logo-atom\.png\[\]/
      imagesFolder = atom.config.get 'asciidoc-image-helper.imagesFolder'
      stat = fs.statSync path.join directory, imagesFolder, imageName
      expect(stat).toBeDefined()
      expect(stat.size).toBe 6258


  it 'create a link and store the image in a directory when image folder append to link and use custom directory', ->
    called = false
    asciiDocimageHelper.onDidInsert -> called = true

    atom.config.set 'asciidoc-image-helper.appendImagesFolder', true # Default
    atom.config.set 'asciidoc-image-helper.enableUrlSupport', true
    atom.config.set 'asciidoc-image-helper.imagesFolder', 'foo'

    editor = atom.workspace.getActiveTextEditor()
    expect(editor.getPath()).toMatch /^.*(\/|\\)foobar\.adoc$/

    editor.selectAll()
    expect(editor.getSelectedText()).toMatch /^foobar$/
    editor.delete()

    imageUrl = path.join __dirname, 'fixtures', imageName
    clipboard.writeText imageUrl
    atom.commands.dispatch workspaceElement, 'core:paste'

    waitsFor 'markup insertion', -> called is true

    runs ->
      editor.selectAll()
      expect(editor.getSelectedText()).toMatch /image::foo(\/|\\)logo-atom\.png\[\]/
      imagesFolder = atom.config.get 'asciidoc-image-helper.imagesFolder'
      stat = fs.statSync path.join directory, imagesFolder, imageName
      expect(stat).toBeDefined()
      expect(stat.size).toBe 6258


  it 'create a link and store the image in a directory when image folder not append to link and use the default directory', ->
    called = false
    asciiDocimageHelper.onDidInsert -> called = true

    atom.config.set 'asciidoc-image-helper.appendImagesFolder', false
    atom.config.set 'asciidoc-image-helper.enableUrlSupport', true

    editor = atom.workspace.getActiveTextEditor()
    expect(editor.getPath()).toMatch /^.*(\/|\\)foobar\.adoc$/

    editor.selectAll()
    expect(editor.getSelectedText()).toMatch /^foobar$/
    editor.delete()

    imageUrl = path.join __dirname, 'fixtures', imageName
    clipboard.writeText imageUrl
    atom.commands.dispatch workspaceElement, 'core:paste'

    waitsFor 'markup insertion', -> called is true

    runs ->
      editor.selectAll()
      expect(editor.getSelectedText()).toBe 'image::logo-atom.png[]'
      imagesFolder = atom.config.get 'asciidoc-image-helper.imagesFolder'
      stat = fs.statSync path.join directory, imagesFolder, imageName
      expect(stat).toBeDefined()
      expect(stat.size).toBe 6258


  it 'create a link and store the image in a directory when image folder not append to link and use custom directory', ->
    called = false
    asciiDocimageHelper.onDidInsert -> called = true

    atom.config.set 'asciidoc-image-helper.appendImagesFolder', false
    atom.config.set 'asciidoc-image-helper.enableUrlSupport', true
    atom.config.set 'asciidoc-image-helper.imagesFolder', 'bar'

    editor = atom.workspace.getActiveTextEditor()
    expect(editor.getPath()).toMatch /^.*(\/|\\)foobar\.adoc$/

    editor.selectAll()
    expect(editor.getSelectedText()).toMatch /^foobar$/
    editor.delete()

    imageUrl = path.join __dirname, 'fixtures', imageName
    clipboard.writeText imageUrl
    atom.commands.dispatch workspaceElement, 'core:paste'

    waitsFor 'markup insertion', -> called is true

    runs ->
      editor.selectAll()
      expect(editor.getSelectedText()).toBe 'image::logo-atom.png[]'
      imagesFolder = atom.config.get 'asciidoc-image-helper.imagesFolder'
      stat = fs.statSync path.join directory, imagesFolder, imageName
      expect(stat).toBeDefined()
      expect(stat.size).toBe 6258
