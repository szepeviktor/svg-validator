#!/bin/bash
#
# Format an SVG file and write it to formatted/ directory
#

set -e

SVG_NS_URL='http://www.w3.org/2000/svg'

SVG_FILE_PATH="$1"

test -r "${SVG_FILE_PATH}"

mkdir -p formatted

xmlstarlet edit -N svg="${SVG_NS_URL}" --delete '//svg:svg/@xml:space' "${SVG_FILE_PATH}" \
    | XMLLINT_INDENT="    " xmllint --format - \
    | xmlstarlet edit --pf -N svg="${SVG_NS_URL}" --append '//svg:svg' --type attr -n 'xml:space' --value 'preserve' \
    > "formatted/${SVG_FILE_PATH}"
