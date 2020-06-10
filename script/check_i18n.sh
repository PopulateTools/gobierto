#!/bin/bash

changes=`git status | grep -E 'config/locales/' | wc -l`
if [ $changes -gt 0 ]; then
  echo "I18n changes detected. Running normalization...."
  i18n-tasks normalize && i18n-tasks health && git add config/locales/
fi
