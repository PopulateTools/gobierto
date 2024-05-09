import '../../../../assets/stylesheets/accessibility.css';

import axeCore from 'axe-core'

let cache = {}
let style = {}
let lastNotification = ''

const deferred = {}
const impacts = [...axeCore.constants.impact].reverse()

export function checkAndReportAccessibility (node, label) {
  const deferred = createDeferred()
  style = { ...defaultOptions.style }

  axeCore.run(node || document, defaultOptions.runOptions, (error, results) => {
    if (error) deferred.reject(error)
    if (results && !results.violations.length) return
    if (JSON.stringify(results.violations) === lastNotification) return

    defaultOptions.customResultHandler ? defaultOptions.customResultHandler(error, results) : standardResultHandler(error, results, label)
    deferred.resolve()
    lastNotification = JSON.stringify(results.violations)
  })
  return deferred.promise
}

const standardResultHandler = function (errorInfo, results, label) {
  results.violations = results.violations.filter(result => {
    result.nodes = result.nodes.filter(node => {
      const key = node.target.toString() + result.id
      const retVal = (!cache[key])
      cache[key] = key
      return retVal
    })
    return (!!result.nodes.length)
  })

  if (results.violations.length) {
    const violations = sortViolations(results.violations)
    console.group(`%cAxe issues ${label ? '- ' + label : ''}`, style.head)
    violations.forEach(result => {
      console.groupCollapsed('%c%s%c %s %s %c%s', style[result.impact || 'minor'], result.impact, style.title, result.help, '\n', style.url, result.helpUrl)
      result.nodes.forEach(node => {
        failureSummary(node, 'any')
        failureSummary(node, 'none')
      })
      console.groupEnd()
    })
    console.groupEnd()
  }
}

export function resetCache () {
  cache = {}
}

export function resetLastNotification () {
  lastNotification = ''
}

export const draf = (cb) => requestAnimationFrame(() => requestAnimationFrame(cb))

function sortViolations (violations) {
  let sorted = []
  impacts.forEach(impact => {
    sorted = [...sorted, ...violations.filter(violation => violation.impact === impact)]
  })
  return sorted
}

function createDeferred () {
  deferred.promise = new Promise((resolve, reject) => {
    deferred.resolve = resolve
    deferred.reject = reject
  })
  return deferred
}

function failureSummary (node, key) {
  if (node[key].length > 0) {
    logElement(node, console.groupCollapsed)
    logHtml(node)
    logFailureMessage(node, key)

    var relatedNodes = []
    node[key].forEach(check => {
      relatedNodes = relatedNodes.concat(check.relatedNodes)
    })

    if (relatedNodes.length > 0) {
      console.groupCollapsed('Related nodes')
      relatedNodes.forEach(relatedNode => {
        logElement(relatedNode, console.log)
        logHtml(relatedNode)
      })
      console.groupEnd()
    }
    console.groupEnd()
  }
}

function logElement (node, logFn) {
  const el = document.querySelector(node.target.toString())
  if (!el) {
    return logFn('Selector: %c%s', style.boldCourier, node.target.toString())
  }
  logFn('Element: %o', el)
}

function logHtml (node) {
  console.log('HTML: %c%s', style.boldCourier, node.html)
}

function logFailureMessage (node, key) {
  const message = axeCore._audit.data.failureSummaries[key]
    .failureMessage(node[key]
      .map(function (check) {
        return check.message || ''
      }))
  console.error(message)
}

export const defaultOptions = {
  auto: true,
  allowConsoleClears: true,
  clearConsoleOnUpdate: false,
  delay: 500,
  config: {
    branding: {
      application: 'vue-axe'
    }
  },
  runOptions: {
    reporter: 'v2',
    resultTypes: ['violations']
  },
  style: {
    head: 'padding:6px;font-size:20px;font-weight:bold;',
    boldCourier: 'font-weight:bold;font-family:Courier;',
    moderate: 'padding:2px 4px;border-radius:5px;background-color:#FFBA52;color:#222;font-weight:normal;',
    critical: 'padding:2px 4px;border-radius:5px;background-color:#AD0000;color:#fff;font-weight:normal;',
    serious: 'padding:2px 4px;border-radius:5px;background-color:#333;color:#FFCE85;font-weight:normal;',
    minor: 'padding:2px 4px;border-radius:5px;background-color:#333;color:#FFCE85;font-weight:normal;',
    title: 'font-color:black;font-weight:bold;',
    url: 'font-color:#4D4D4D;font-weight:normal;'
  },
  plugins: []
}

export function clear (forceClear = false, options) {
  resetCache()
  if (forceClear || options.clearConsoleOnUpdate) {
    resetLastNotification()
    if (options.allowConsoleClears) {
      console.clear()
    }
  }
}
