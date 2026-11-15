a <- commandArgs(TRUE); racine <- a[1]; cas <- a[2]; chemin <- a[3]
source(file.path(racine, "docs/revues/20261115-s1-rejeu/sondes/forge.R"))
source(file.path(racine, "R", "charger_moteur.R")); charger_moteur(file.path(racine, "R", "engine.R"))
if (identical(chemin, "interne")) assign("requireNamespace", function(package, ...) if (package %in% "openxlsx") FALSE else base::requireNamespace(package, ...), envir = environment(run_engine))
cs <- function(v) sprintf('<c r="B2" t="s"><v>%s</v></c>', v)
ent <- ligne(1, ci("A1", "t"), ci("B1", "xt"))
L <- function(b) c(ent, ligne(2, cn("A2", 1), b))
C <- switch(cas,
  neg      = list(L(cs("-1")), "<si><t>a</t></si>"),
  neg0     = list(L(cs("-0")), NULL),
  is_s     = list(L('<c r="B2" t="s"><is><t>11</t></is></c>'), "<si><t>a</t></si>"),
  si_vide1 = list(L(cs("1")), "<si/><si><t>x</t></si>"),
  si_vide0 = list(L(cs("0")), "<si/><si><t>x</t></si>"),
  n0_txt   = list(L(cs("abc")), NULL),
  n0_nan   = list(L(cs("NaN")), NULL),
  n0_vide  = list(L(cs("")), NULL),
  comm     = list(L(cs("1")), "<si><t>a</t></si><!--<si><t>b</t></si>-->"),
  frac     = list(L(cs("0.5")), "<si><t>a</t></si>"),
  frac2    = list(L(cs("0.99999999999999999999")), "<si><t>a</t></si>"),
  hex      = list(L(cs("0x0")), "<si><t>a</t></si>"),
  inf      = list(L(cs("1e400")), "<si><t>a</t></si>"),
  attr_v   = list(L('<c r="B2" t="s"><v xml:space="preserve">5</v></c>'), "<si><t>a</t></si>"),
  v_esp    = list(L('<c r="B2" t="s"><v >5</v></c>'), "<si><t>a</t></si>"),
  v_pfx    = list(L('<c r="B2" t="s"><x:v>5</x:v></c>'), "<si><t>a</t></si>"),
  t_apos   = list(L("<c r='B2' t='s'><v>5</v></c>"), "<si><t>a</t></si>"),
  t_blanc  = list(L('<c r="B2" t = "s"><v>5</v></c>'), "<si><t>a</t></si>"),
  v_maj    = list(L('<c r="B2" t="s"><V>5</V></c>'), "<si><t>a</t></si>"),
  neg2     = list(L(cs("-2")), "<si><t>a</t></si><si><t>b</t></si>"),
  si_num   = list(L(cs("0")), "<si/><si><t>11.5</t></si>"),
  ok1      = list(L(cs("0")), "<si><t>a</t></si>"),
  stop("cas"))
f <- forger(C[[1]], C[[2]])
r <- tryCatch(engine_lire_xlsx(f), error = function(e) e)
cat(cas, chemin, ":", class(r)[1], "|", if (inherits(r, "condition")) substr(conditionMessage(r), 1, 160) else paste(capture.output(print(r)), collapse=" / "), "\n")
