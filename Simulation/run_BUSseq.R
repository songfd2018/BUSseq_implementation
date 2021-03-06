#Apply BUSseq to the simulation study.

rm(list=ls())
library(BUSseq)

########################
# Load Simulation Data #
########################
# Working directory
# setwd("G:/scRNA/Journal/Github_reproduce/Simulation")

# Loading the file name list of all simulation count data
file_list <- list.files("./RawCountData")
file_list <- file_list[grepl("sim_count_data", file_list)]
B <- length(file_list)
SimulatedCounts <- list()
for(b in 1:B){
  file_name <- paste0("./RawCountData/",file_list[b])
  SimulatedCounts[[b]] <- as.matrix(read.table(file_name,header = T))
}


#######################################
# Apply BUSseq to the Simulation Data #
#######################################
# the seed is a randomly sampled integer between 1 and 10,000 
seed.est <- 2116

# We've conduct the posterior infernce for the number of cell types K equal to  
# 3, 4, 5, 6, 7, 8 and select K = 5
K <- 5

# Conducting MCMC sampling
BUSseqfits_simulation <- BUSseq_MCMC(ObservedData = SimulatedCounts, n.celltypes = K,
                                     hyper_tau0 = c(2, 0.01),
                                     n.iterations = 3000, seed = seed.est)

# # BIC values of other numbers of cell types are generated by the following codes
# # all seeds are randomly sampled between 1 and 10,000.
# # We strongly recommend to run the BUSseq_MCMC parallelly.
#
# BUSseqfits_K3 <- BUSseq_MCMC(Data = SimulatedCounts, n.celltypes = 3,
#                                      hyper_tau0 = c(2, 0.01),
#                                      n.iterations = 3000, seed = 18)
# BUSseqfits_K4 <- BUSseq_MCMC(Data = SimulatedCounts, n.celltypes = 4,
#                                      hyper_tau0 = c(2, 0.01),
#                                      n.iterations = 3000, seed = 6112)
# BUSseqfits_K6 <- BUSseq_MCMC(Data = SimulatedCounts, n.celltypes = 6,
#                                      hyper_tau0 = c(2, 0.01),
#                                      n.iterations = 3000, seed = 3733)
# BUSseqfits_K7 <- BUSseq_MCMC(Data = SimulatedCounts, n.celltypes = 7,
#                                      hyper_tau0 = c(2, 0.01),
#                                      n.iterations = 3000, seed = 3626)
# BUSseqfits_K8 <- BUSseq_MCMC(Data = SimulatedCounts, n.celltypes = 8,
#                                      hyper_tau0 = c(2, 0.01),
#                                      n.iterations = 3000, seed = 4856)
# BIC_values <- rep(NA,6)
# BIC_values[1] <- BIC_BUSseq(BUSseqfits_K3)
# BIC_values[2] <- BIC_BUSseq(BUSseqfits_K4)
# BIC_values[3] <- BIC_BUSseq(BUSseqfits_simulation)
# BIC_values[4] <- BIC_BUSseq(BUSseqfits_K6)
# BIC_values[5] <- BIC_BUSseq(BUSseqfits_K7)
# BIC_values[6] <- BIC_BUSseq(BUSseqfits_K8)
# names(BIC_values) <- paste0("K=",3:8)
# # As a result, the BIC values shown in the Fig 3j are
# #  K=3      K=4      K=5      K=6      K=7      K=8 
# # 55101445 55075127 55034465 55189786 55466582 55507751 
#
# png("./Image/Other/BIC_values.png",width = 540, height = 720)
# par(mar = c(5.1,6.1,4.1,2.1)) 
# plot(3:8,BIC_values,xlab= "K",ylab = "BIC",type="n",cex.axis=3,cex.lab=3)
# points(3:8,BIC_values,type="b",pch=19,cex=3)
# dev.off()

#####################################
# Obtain the intrinsic gene indices #
#####################################
intrinsic_gene_indices <- intrinsic_genes_BUSseq(BUSseqfits_simulation, fdr_threshold =  0.05)


##################################
# Obain the cell type indicators #
##################################
w.est <- celltypes(BUSseqfits_simulation)
w_BUSseq <- unlist(w.est) # change the list of cell type indicators to a vector


########################################
# Obtain the corrected read count data #
########################################
set.seed(12345)
corrected_count_est <- corrected_read_counts(BUSseqfits_simulation)
log_corrected_count_est <- NULL
for(b in 1:B){
  log_corrected_count_est <- cbind(log_corrected_count_est, log1p(corrected_count_est[[b]]))
}


# Store the workspace
if(!dir.exists("Workspace")){
  dir.create("Workspace")
}

save.image("./Workspace/BUSseq_workspace.RData")