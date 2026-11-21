ta <- matrix(c(357848, 352118, 290507, 310608, 443160, 396132, 440832, 359480, 376686, 344014,
  1124788, 1236139, 1292306, 1418858, 1136350, 1333217, 1288463, 1421128, 1363294, NA,
  1735330, 2170033, 2218525, 2195047, 2128333, 2180715, 2419861, 2864498, NA, NA,
  2218270, 3353322, 3235179, 3757447, 2897821, 2985752, 3483130, NA, NA, NA,
  2745596, 3799067, 3985995, 4029929, 3402672, 3691712, NA, NA, NA, NA,
  3319994, 4120063, 4132918, 4381982, 3873311, NA, NA, NA, NA, NA,
  3466336, 4647867, 4628910, 4588268, NA, NA, NA, NA, NA, NA,
  3606286, 4914039, 4909315, NA, NA, NA, NA, NA, NA, NA,
  3833515, 5339085, NA, NA, NA, NA, NA, NA, NA, NA,
  3901463, NA, NA, NA, NA, NA, NA, NA, NA, NA), 10, 10)
out <- NULL
for (J1 in c(10, 9, 7, 5)) {
  tri <- ta[, 1:J1]; a <- ajuste_B(tri); m <- msep_B(tri, a); c <- cl_msep(tri, a)
  out <- rbind(out, data.frame(geom = sprintf("10x%d", J1), msep_B = m$msep, msep_CL = c$msep,
    ecart_rel = abs(m$msep - c$msep)/c$msep, R = m$reserve, s2_regle = a$s2[a$J], s2_direct = a$s2_direct))
}
print(out, digits = 15)
aj <- mw_ajuster(ta); cat(sprintf("moteur 10x10 : %.10f ; racine %.6f\n", mw_msep(aj)$msep, sqrt(mw_msep(aj)$msep)))
