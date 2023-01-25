#!/usr/bin/env bash

diamond makedb \
    --in $in \
    --db $db \
    --taxonmap $taxonmap \
    --taxonnodes $taxonnodes \
    --taxonnames $taxonnames 