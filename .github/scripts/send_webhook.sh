#!/bin/sh

echo "$STEPS_CONTEXT" | jq --raw-output \
  --arg workflow_url "$GITHUB_SERVER_URL/$GITHUB_REPOSITORY/actions/runs/$GITHUB_RUN_ID" \
  --arg timestamp "$(date --iso-8601=minutes)" \
'[
  to_entries[] |
  select(.key | startswith("check-")) |
  .value |= .outcome |
  {
    name: .key,
    value,
    inline: false
  }
] |
{
  embeds: [{
    title: "Everest Wiki Workflow Run",
    description: "Checks failed",
    url: $workflow_url,
    color: 16711680,
    fields: .,
    timestamp: $timestamp,
    footer: {
      text: "This Action is run Mon/Wed/Fri at 18:00UTC"
    }
  }],
  allowed_mentions: ({
    parse: []
  })
}' | curl -X POST -H "Content-Type: application/json" --data @- "$WEBHOOK_URL"
