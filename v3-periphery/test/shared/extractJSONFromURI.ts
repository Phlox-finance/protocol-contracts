export function extractJSONFromURI(uri: string): {
  name: string
  description: string
  image?: string
  images?: any[]
  attributes?: { key: string; value: string; type: string }[]
} {
  const str = uri.startsWith('0x') ? Buffer.from(uri.slice(2), 'hex').toString('utf8') : uri
  const encodedJSON = str.substr('data:application/json;base64,'.length)
  const decodedJSON = Buffer.from(encodedJSON, 'base64').toString('utf8')
  const parsed = JSON.parse(decodedJSON)
  if (parsed.LSP4Metadata) {
    return parsed.LSP4Metadata
  }
  return parsed
}
