const dasherize = (input: string): string => {
    return input.replaceAll(" ", "-").toLowerCase()
}

export default dasherize
