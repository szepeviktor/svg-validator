#!/bin/bash
#
# Validate an SVG file against Scalable Vector Graphics (SVG) 1.1 specification
#
# REFS          :https://www.w3.org/TR/SVG11/
# REFS          :https://github.com/oreillymedia/HTMLBook/tree/master/schema/svg
# DEPENDS       :apt-get install xmlstarlet libxml2-utils

set -e -o pipefail

shopt -s globstar dotglob nullglob

SVG_XML_DECLARATION='<?xml version="1.0" standalone="no"?>'
SVG_DOCTYPE='<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">'
SVG_NS_URL='http://www.w3.org/2000/svg'
SVG_VERSION='1.1'
ACTION_FAILED="false"

Check() {
    local SVG_FILE_PATH="$1"

    if ! test -r "${SVG_FILE_PATH}"; then
        echo "File not found" 1>&2
        return 10
    fi

    # First line
    if ! diff <(sed -n -e '1p' "${SVG_FILE_PATH}") - <<<"${SVG_XML_DECLARATION}"; then
        echo "Missing XML declaration" 1>&2
        return 11
    fi
    # Second line
    if ! diff <(sed -n -e '2p' "${SVG_FILE_PATH}") - <<<"${SVG_DOCTYPE}"; then
        echo "Missing doctype" 1>&2
        return 12
    fi
    # SVG version
    if ! diff --ignore-space-change <(
        xmlstarlet format --dropdtd "${SVG_FILE_PATH}" \
            | xmlstarlet select -N svg="${SVG_NS_URL}" --template --value-of '/svg:svg/@version'
        ) - <<<"${SVG_VERSION}"; then
        echo "Invalid SVG version" 1>&2
        return 13
    fi
    # Check formatting without xml:space attribute
    if ! diff <(
        xmlstarlet edit -N svg="${SVG_NS_URL}" --delete '//svg:svg/@xml:space' "${SVG_FILE_PATH}" \
            | XMLLINT_INDENT="    " xmllint --format - \
            | xmlstarlet edit --pf -N svg="${SVG_NS_URL}" --append '//svg:svg' --type attr -n 'xml:space' --value 'preserve'
        ) "${SVG_FILE_PATH}"; then
        echo "Invalid xml:space attribute" 1>&2
        return 14
    fi
    # Validation against SVG schema
    if ! xmllint --noout --schema /usr/local/share/xml/SVG.xsd "${SVG_FILE_PATH}"; then
        echo "Schema violation" 1>&2
        return 15
    fi
}

if [ -z "${INPUT_SVG_PATH}" ]; then
    echo "No SVG files specified!"
    exit 10
fi

# Validate schemas
xmllint --noout --schema /usr/local/share/xml/XMLSchema.xsd /usr/local/share/xml/xml.xsd
xmllint --noout --schema /usr/local/share/xml/XMLSchema.xsd /usr/local/share/xml/xlink.xsd
xmllint --noout --schema /usr/local/share/xml/XMLSchema.xsd /usr/local/share/xml/SVG.xsd

# Validate SVG files
# shellcheck disable=SC2086
for SVG in ${INPUT_SVG_PATH}; do
    if ! Check "${SVG}"; then
        ACTION_FAILED="true"
        echo "::error file=${SVG},title=SVG Validator::Validation failed for ${SVG}"
    fi
done

if [ "${ACTION_FAILED}" != false ]; then
    exit 20
fi

exit 0
