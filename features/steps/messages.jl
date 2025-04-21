# MIT License
#
# Copyright (c) 2024 Erik Edin
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#

using Behavior
using NonaNats
using JSON

const eventtypes = Dict{String, Type}(
    "NewGameEvent" => NewGameEvent,
)

# Reads a table with two columns as a key/value table,
# and produces a Dict from it.
function associativetable(context)
    keyvalues = [
        (row[1], row[2])
        for row in context.datatable
    ]
    Dict{String, String}(keyvalues)
end

@given("a payload on the subject '{String}'") do context, subject

end

@when("the message is translated") do context
    subject = context[:subject]
    payload = context[:payload]
    ev = NonaNats.translate(subject, payload)

    context[:event] = ev
end

@then("it is a {String} with fields") do context, eventtypename
    ev = context[:event]

    # This is the table of fields that should be checked.
    fields = associativetable(context)

    # The event type is found via the eventtypes lookup table.
    expectedtype = eventtypes[eventtypename]

    @expect typeof(ev) == expectedtype
    for field in fields
        # TODO Check fields
        @expect false
    end
end