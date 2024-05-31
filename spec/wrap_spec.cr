require "./spec_helper"

LOREMIPSUM = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."

describe String do
  it "doesn't alter the string if the width is negative" do
    str = "this is some text"

    str.wrap(-1).should eq str
  end

  it "doesn't alter a line that is too short to wrap" do
    str = "this is some short text"

    str.wrap.should eq str
    str.wrap(100).should eq str
  end

  it "wraps a line of text, with no large words or non-word entries" do
    str = LOREMIPSUM

    str.wrap.should eq <<-EOS
    Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor
    incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis
    nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.
    Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore
    eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt
    in culpa qui officia deserunt mollit anim id est laborum.
    EOS
  end

  it "wraps a line of text, with no large words or non-word entries, but with a very small line length" do
    str = LOREMIPSUM

    str.wrap(10).should eq <<-EOS
    Lorem
    ipsum
    dolor
    sit
    amet, con-
    sectetur
    adipiscing
    elit,
    sed do
    eiusmod
    tempor
    incididunt
    ut
    labore
    et
    dolore
    magna
    aliqua.
    Ut enim
    ad minim
    veniam,
    quis
    nostrud
    exercitation
    ullamco
    laboris
    nisi ut
    aliquip
    ex ea
    commodo
    consequat.
    Duis
    aute
    irure
    dolor in
    reprehenderit
    in volupt-
    ate
    velit
    esse
    cillum
    dolore
    eu
    fugiat
    nulla par-
    iatur.
    Excepteur
    sint occa-
    ecat cupi-
    datat
    non proid-
    ent,
    sunt in
    culpa
    qui
    officia
    deserunt
    mollit
    anim id
    est
    laborum.
    EOS
  end

  it "wraps a line of text, with an atypically large word at the split point" do
    str = LOREMIPSUM.sub(/tempor/, "supercalifragilisticexpialidocious")

    str.wrap(35).should eq <<-EOS
    Lorem ipsum dolor sit amet, consec-
    tetur adipiscing elit, sed do
    eiusmod supercalifragilisticexpial-
    idocious incididunt ut labore et
    dolore magna aliqua. Ut enim ad
    minim veniam, quis nostrud exercit-
    ation ullamco laboris nisi ut
    aliquip ex ea commodo consequat.
    Duis aute irure dolor in reprehend-
    erit in voluptate velit esse
    cillum dolore eu fugiat nulla
    pariatur. Excepteur sint occaecat
    cupidatat non proident, sunt in
    culpa qui officia deserunt mollit
    anim id est laborum.
    EOS
  end

  it "should avoid wrapping a directory path, even if that path is in other wrapped text" do
    str = "this is a path: /this/is/a/long/path/that/should/not/be/wrapped but we don't want that path to wrap"

    str.wrap(35).should eq <<-EOS
    this is a path:
    /this/is/a/long/path/that/should/not/be/wrapped
    but we don't want that path to
    wrap
    EOS
  end

  it "should avoid wrapping a directory path, even if that path is in other wrapped text, and should handle terminal newlines" do
    str = "this is a path: /this/is/a/long/path/that/should/not/be/wrapped\n"

    str.wrap(35).should eq <<-EOS
    this is a path:
    /this/is/a/long/path/that/should/not/be/wrapped\n
    EOS
  end

  it "should preserve indentation when wrapping" do
    str = <<-EOS
    here are some words:

        And here is some indented stuff that is long enough to wrap and wrap and wrap, because we want to see indents wrapped.

        And here are some more words.
        And blah blah blah wrap wrap wrap we blather on in order to get another long line what will wrap.

    And back to unindented content.
    EOS

    str.wrap(40).should eq <<-EOS
    here are some words:

        And here is some indented stuff
        that is long enough to wrap and
        wrap and wrap, because we want to
        see indents wrapped.

        And here are some more words.
        And blah blah blah wrap wrap wrap
        we blather on in order to get anoth-
        er long line what will wrap.

    And back to unindented content.
    EOS
  end

  it "should handle multiple levels of indentation" do
    str = <<-EOS
    here are some words:

        And here is some indented stuff that is long enough to wrap and wrap and wrap, because we want to see indents wrapped.

            And here are some more words.
            And blah blah blah wrap wrap wrap we blather on in order to get another long line what will wrap.

    And back to unindented content.
    EOS

    str.wrap(40).should eq <<-EOS
    here are some words:

        And here is some indented stuff
        that is long enough to wrap and
        wrap and wrap, because we want to
        see indents wrapped.

            And here are some more words.
            And blah blah blah wrap wrap
            wrap we blather on in order to
            get another long line what
            will wrap.

    And back to unindented content.
    EOS
  end

  it "should preserve indentation when wrapping, and handle un-splittable content" do
    str = <<-EOS
    here are some words:

        And here is some indented /this/is/a/long/path/that/should/not/be/wrapped stuff that is long enough to wrap and wrap and wrap, because we want to see indents wrapped.

        And here are some more words.
        And blah blah blah wrap wrap wrap we blather on in order to get another long line what will wrap.

    And back to unindented content.
    EOS

    str.wrap(40).should eq <<-EOS
    here are some words:

        And here is some indented
        /this/is/a/long/path/that/should/not/be/wrapped
        stuff that is long enough to wrap
        and wrap and wrap, because we want
        to see indents wrapped.

        And here are some more words.
        And blah blah blah wrap wrap wrap
        we blather on in order to get
        another long line what will wrap.

    And back to unindented content.
    EOS
  end

  it "can wrap without using hyphenation" do
    str = <<-EOS
    This is a helper function for nicely formatting strings with natural-appearing line wrapping. It takes a string and breaks it into lines of a maximum length, inserting newlines where necessary. It also attempts to break lines at word boundaries, and to avoid breaking lines in the middle of words. It does this by calculating the average word length and standard deviation of word length, and using these to determine the maximum word length to allow before breaking.

    Words that are longer than the maximum word length (i.e. a word length that is larger than typical, and which would thus cause the text appearance to be peculiar, with a large end-of-line gap) are broken at a point that is generally 20% - 80% of the way through the word using a hyphen. The algorithm also refuses to break a word that starts with a non-letter character, to avoid breaking things like directory paths.

    Finally, the algorithm maintains the indetation at the start of a line, when a line is broken into multiple lines. This maintains text formatting, for complex text, such as help text or documents with examples.
    EOS

    str.wrap(hyphenate: false).should eq <<-EOS
    This is a helper function for nicely formatting strings with natural-appearing
    line wrapping. It takes a string and breaks it into lines of a maximum length,
    inserting newlines where necessary. It also attempts to break lines at word
    boundaries, and to avoid breaking lines in the middle of words. It does this
    by calculating the average word length and standard deviation of word length,
    and using these to determine the maximum word length to allow before breaking.

    Words that are longer than the maximum word length (i.e. a word length that is
    larger than typical, and which would thus cause the text appearance to be
    peculiar, with a large end-of-line gap) are broken at a point that is
    generally 20% - 80% of the way through the word using a hyphen. The algorithm
    also refuses to break a word that starts with a non-letter character, to avoid
    breaking things like directory paths.

    Finally, the algorithm maintains the indetation at the start of a line, when a
    line is broken into multiple lines. This maintains text formatting, for
    complex text, such as help text or documents with examples.
    EOS
  end
end
