import type { Register } from 'claude-code'

// "claude-opus-5-5" -> "Opus 5.5"; anything else is shown as given
const pretty = (id: string) => {
  const m = id.match(/^claude-([a-z]+)-(\d+)-(\d+)/)
  return m ? `${m[1][0].toUpperCase()}${m[1].slice(1)} ${m[2]}.${m[3]}` : id
}

export const register: Register = on => {
  on('ui.render', { component: 'PromptHint' }, async ($, e, next) => {
    const model = pretty(await $.session.model())
    return next({ ...e, props: { ...e.props, tail: model } })
  })
}
