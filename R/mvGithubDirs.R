ff = list.files()
i = file.info(ff)
table(i$isdir)
dirs = ff[i$isdir]
confs = file.path(dirs, ".git/config")
ex = file.exists(confs)
dirs = dirs[ex]
confs = confs[ex]
url = sapply(confs, function(f) grep("url =", readLines(f), value = TRUE))
w = grepl("github.com", url)

sapply(dirs[w], function(d) file.rename(d, file.path("github", d)) )


#
# Users
u = gsub("^[[:space:]]+url = ", "", url)
library(XML)
user = gsub("^/", "", sapply(u, function(x) dirname(parseURI(x)$path)))

byUser = split(dirs, user)

dsort(table(user))
