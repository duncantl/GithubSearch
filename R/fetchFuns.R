if(FALSE) {
    con = getCurlHandle(cookie = cookie("gh.cookie"),
                        followlocation = TRUE,
                        useragent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:105.0) Gecko/20100101 Firefox/105.0",
                        verbose = FALSE, cookiejar = "",
                        referer = "https://github.com/search/advanced")
    sim = ghSearch(con, "simulation")

    agent.based = ghSearch(con, "agent+based")
    script = ghSearch(con, "script")

    z = list(sim = sim, agent.based = agent.based, script = script)
    saveRDS(z, "GHResults.rds")

    length(unique(unlist(z)))
    length(unlist(z))

    cmds = sprintf("git clone %s", u)
    sapply(cmds, function(op) try(system(op)))
}

ghSearch =
    # Limits to 100 pages of size 10.
function(con, q, language = "R", maxNum = Inf, delay = 2) # 3 works.
{
#    browser()
#    tt = getForm("https://github.com/search", q = sprintf("language:%s+%s", language, q),
#                     type = "repositories", curl = con)

    u = sprintf("https://github.com/search?q=language:%s+%s&type=repositories", language, q)
    tt = getURLContent(u, curl = con)
    
    doc = htmlParse(tt)

    page = 2L
    ans = getPageInfo(doc)
    while(length( nxt <- getNextPageURL(doc)) && length(ans) < maxNum) {
        Sys.sleep(delay)
        message("next page ", page)
        doc = htmlParse(getURLContent(nxt, curl = con))
        ans = c(ans, getPageInfo(doc))
        page = page + 1L
    }

    ans
}


getPageInfo =
function(doc)
{
    ll = getNodeSet(doc, "//a[contains(@data-hydro-click, 'https://github.com/')]")
    h = sapply(ll, xmlGetAttr, "data-hydro-click")
    ru = sapply(h, function(x) fromJSON(x)$payload$result$url)
    ru[ !sapply(ru, is.null) ]
}


getNextPageURL =
function(doc,  base = "https://github.com/search")
{
    nxt = getNodeSet(doc, "//a[@rel = 'next']/@href")
    if(length(nxt))
        getRelativeURL(nxt[[1]], "https://github.com/search")
    else
        character()
}




#####################

cloneRepos =
function(u, dir = character())
{
    u = unique(unlist(u))
    b = basename(u)
    w = duplicated(b)
    trgt = character(length(u))
    if(any(w)) 
        trgt[w]  = sprintf("%s_%s", basename(dirname(u[w])), basename(u[w]))
    
    cmds = sprintf("git clone %s %s", u, trgt)
    if(length(dir) && file.exists(dir)) {
        old = getwd()
        on.exit(setwd(old))
        setwd(dir)
    }
    
    status = sapply(cmds, function(op) try(system(op)))
}
