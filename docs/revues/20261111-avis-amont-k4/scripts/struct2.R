x <- readRDS("tests/reference/premium.rds")
str(x$tests, max.level=2, list.len=4)
x2 <- readRDS("tests/reference/reserve2.rds"); str(x2$tests, max.level=2, list.len=3)
str(x$validation)
