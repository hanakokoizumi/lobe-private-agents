addEventListener('fetch', event => {
    event.respondWith(handleRequest(event.request))
  })
  
  async function handleRequest(request) {
    const url = new URL(request.url)
    const path = url.pathname
  
    let response
  
    if (path === '/index.json' || path === '/index.zh-CN.json') {
      let githubResponse = await fetch(`https://raw.githubusercontent.com/hanakokoizumi/lobe-private-agents/indexed/index${path}`)
      let chatResponse = await fetch(`https://chat-agents.lobehub.com${path}`)
  
      if (githubResponse.status === 200 && chatResponse.status === 200) {
        let githubData = await githubResponse.json()
        let chatData = await chatResponse.json()
  
        let combinedTags = Array.from(new Set([...githubData.tags, ...chatData.tags]))
  
        let combinedAgents = {}
        githubData.agents.forEach(agent => {
          combinedAgents[agent.identifier] = agent
        })
        chatData.agents.forEach(agent => {
          combinedAgents[agent.identifier] = agent
        })
  
        let mergedData = {
          schemaVersion: 1,
          tags: combinedTags,
          agents: Object.values(combinedAgents)
        }
  
        response = new Response(JSON.stringify(mergedData), {
          headers: {
            'Content-Type': 'application/json'
          }
        })
      } else {
        response = new Response('Error merging files', { status: 500 })
      }
    } else {
      let githubResponse = await fetch(`https://raw.githubusercontent.com/hanakokoizumi/lobe-private-agents/indexed/agents${path}`)
  
      if (githubResponse.status === 200) {
        response = githubResponse
      } else {
        let chatResponse = await fetch(`https://chat-agents.lobehub.com${path}`)
  
        if (chatResponse.status === 200) {
          response = chatResponse
        } else {
          response = new Response('File not found', { status: 404 })
        }
      }
    }
  
    return response
  }