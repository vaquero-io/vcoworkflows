vcoworkflows CHANGELOG
================

## 0.1.3

### Third Time's the Charm

General cleanup and spit-polish. There are still a few rough spots that'll take some elbow grease, but at least all the parts are in the tin.

- Update gem spec and documentation to reflect the repo being transferred to [activenetwork-automation](https://github.com/activenetwork-automation)
- Set a minimum Ruby version (`>= 2.0`) for the gem (fixes [#9](https://github.com/activenetwork-automation/vcoworkflows/issues/9))
- Fix Coveralls integration for CI ([#7](https://github.com/activenetwork-automation/vcoworkflows/issues/7))
- Deprecate `Workflow#set_parameter` and `Workflow#get_parameter`, as they're not very Ruby-ish, and if we're going to do things, we might as well do things right. I think this might be more right-ish than before. Anyway, they're deprecated in favor of:
  - `Workflow#parameter` - Set an input parameter using name and value:
    ```ruby
    workflow.parameter('foo', 'bar')
    ```

  - `Workflow#parameter=` - Set an input parameter using a WorkflowParameter object:
    ```ruby
    workflow.parameter = VcoWorkflows::WorkflowParameter.new('my_parameter',
                                                             'string',
                                                             value: 'foo')
    ```

  - `Workflow#parameter?` - Determine if an input parameter is set.
    ```ruby
    workflow.parameter? 'foo'
    ```

- Add `Workflow#parameters=` to set all input parameters using a hash, instead of having to set parameter values individually. Basically, `Workflow` will do the work instead of making you do it.
  ```ruby
  input_parameters = { 'name'    => 'a string value',
                       'version' => '2',
                       'words'   => %w(fe fi fo fum) }
  workflow.parameters = input_parameters
  ```

- Added `Guardfile` to aid in development. See what you break as you break it! `rspec`, `rubocop` and `yard` will do their things, until you make them stop.
- Speaking of `rspec`, replaced lots of repetitive typing with a loop, because I'm *smart* like that.
- More fixes and updates to documentation.
- Pull my username out of some of the examples. *Embarrasing...* At least I didn't commit any passwords (yet).

## 0.1.2

- Fix lots of documentation typos

## 0.1.1

- Releases are scary.

## 0.1.0

* Initial setup of gem framework.

*note, at this point the guard implementation throws errors when running. Not sure what the cause is...


Check the [Markdown Syntax Guide](http://daringfireball.net/projects/markdown/syntax) for help with Markdown.
The [Github Flavored Markdown page](http://github.github.com/github-flavored-markdown/) describes the differences between markdown on github and standard markdown.
