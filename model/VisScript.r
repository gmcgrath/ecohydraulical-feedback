library(fields)
#library(rgl)

lookupfdir <-function(fdir) {
   switch(paste(fdir,"",sep=""),
       '1' = c(-1,-1),
       '2' = c(-1,0),
       '3' = c(-1,1),
       '4' = c(0,1),
       '5' = c(1,1),
       '6' = c(1,0),
       '7' = c(1,-1),
       '8' = c(0,-1),
       '9' = c(0,0),
           c(-2,-2)
   )
}

fdirPlot <- function(imData,fdirs) {
  dimDat<- dim(imData)
  disCols <- two.colors(n=64, start="lightskyblue1", end="blue4", middle="royalblue2")
  image(imData,axes=FALSE, col=colsVeg,zlim=c(1,9))
  for (i in 1:dimDat[1]) {
  for (j in 1:dimDat[2]) {
  dxdy <- lookupfdir(fdirs[i,j])
  if (dxdy[1] != -2) {
   lines(rbind(c(i-0.5,j-0.5)/dimDat[1],c(i-dxdy[1]-0.5,j-dxdy[2]-0.5)/dimDat[1]))
   } else {
          if (i==1) {
            lines(rbind(c(i-0.5,j-0.5)/dimDat[1],c(i-1.5,j-0.5)/dimDat[1]))
          } else {
                if (i==dimDat[1]) {
                    lines(rbind(c(i-0.5,j-0.5)/dimDat[1],c(i+1-0.5,j-0.5)/dimDat[1]))
                 } else {
                        if (j==1) { 
                          lines(rbind(c(i-0.5,j-0.5)/dimDat[1],c(i-0.5,j-1-0.5)/dimDat[1]))
                        } else {
                               if (j==dimDat[2]) {
		                 lines(rbind(c(i-0.5,j-0.5)/dimDat[1],c(i-0.5,j+1-0.5)/dimDat[1]))
                               }
                          }
                     }
             }
      }
  }
  }
}

setwd('c:/christoph/paper/gavan/model')

colsVeg <- two.colors(n=9, start="yellow", end="green4", middle="green")
par(oma=c(0,0,0,0))
par(mar=c(0.1,0.1,0.1,0.1))
ndx <- c(1,1,1)
k0 <- (ndx[3]-1)*6+(ndx[2]-1)*6*6+(ndx[1]-1)*6*6*6
par(mfrow=c(3,3))
#layout(matrix(c(1:12),4,3,byrow=TRUE),widths=c(1,1,1,1),heights=c(1,1,1,1))
tsteps <-90
dimres <-90
kk <- 0
nrows <- 32
ncolms <- 32
for (k in 1:1) {
  veg        <-    array(data=NA,dim=c(nrows,ncolms,dimres),dimnames=c("x","y","t"))
  flowdirns  <-    array(data=NA,dim=c(nrows,ncolms,dimres),dimnames=c("x","y","t"))
  #store      <-    array(data=NA,dim=c(nrows,ncols,dimres),dimnames=c("x","y","t"))
  discharge  <-    array(data=NA,dim=c(nrows,ncolms,dimres),dimnames=c("x","y","t"))
  #etActual   <-    array(data=NA,dim=c(nrows,ncols,dimres),dimnames=c("x","y","t"))
  #bareEvap   <-    array(data=NA,dim=c(nrows,ncols,dimres),dimnames=c("x","y","t"))
  topog      <-    array(data=NA,dim=c(nrows,ncolms,dimres),dimnames=c("x","y","t"))
  #infiltProb <-    array(data=NA,dim=c(nrows,ncols,dimres),dimnames=c("x","y","t"))
  strm <-file(paste(paste('TStepResults',1,sep=""),'_1.out',sep=""),open = "r")
  readLines(con=strm,n=1);

  nts <- tsteps
  for (i in 1:nts) {
    readLines(con=strm,n=1);
    dat <- scan(file=strm,what=numeric(0),nlines=nrows,nmax=(ncolms*nrows*8),quiet=TRUE);
    unlink(strm);
    
    if (i>(tsteps-dimres)) {
      dat2 <- matrix(data=dat,nrow=nrows,ncol=ncolms*8,byrow=TRUE)
      
      kk <- kk+1
      veg[,,kk]        <- dat2[,1:nrows]
      flowdirns[,,kk]  <- dat2[,(nrows+1):(2*nrows)]
      discharge[,,kk]  <- dat2[,(3*nrows+1):(4*nrows)] 
      #etActual[,,i]   <- dat2[,(3*nrows+1):(4*nrows)]  
      #bareEvap[,,i]   <- dat2[,(3*nrows+1):(4*nrows)] 
      topog[,,kk]      <- dat2[,(6*nrows+1):(7*nrows)] 
    }
  }
  close(strm)
  
  for (i in c(1:dimres)) {
    image(veg[,,i],asp=1,xlim=c(0,1),ylim=c(0,1),zlim=c(1,9),axes=FALSE,col=colsVeg)
    fdirPlot(discharge[,,i],flowdirns[,,i])
    image(topog[,,i],asp=1,xlim=c(0,1),ylim=c(0,1),axes=FALSE,col=terrain.colors(64))
   }
}

#tm <- 90
#y <- (topog[,,tm]-1000)*10
#x <- 5 * (1:nrows) # 5 meter spacing (S to N)
#z <- 5* (1:ncolms) # 5 meter spacing (E to W)
#ylim <- range(y)
#ylen <- ylim[2] - ylim[1] + 1
#colorlut <- terrain.colors(ylen) # height color lookup table
#col <- colorlut[ y-ylim[1]+1 ] # assign colors to heights for each point
#drape.plot(x,z,y,veg[,,tm],theta=40,phi=-20)
#open3d()
#surface3d(x,z,y, color=col,back="lines")

#pars <- par3d()
#rgl.viewpoint(theta=30,phi=30,fov=30,zoom=1,interactive=TRUE,pars$userMatrix)
#rgl.postscript('/home/hydro/mcgrath/Coupled/terrain4.eps',fmt="eps")
#postscript(file="vegdrainage1.eps")
#par(mfrow=c(2,2))
#for (i in c(1:2)) {
#    image(veg[,,i],asp=1,xlim=c(0,1),ylim=c(0,1),zlim=c(1,9),axes=FALSE,col=colsVeg)
#    fdirPlot(discharge[,,i],flowdirns[,,i])
#    #image(topog[,,i],asp=1,xlim=c(0,1),ylim=c(0,1),axes=FALSE,col=terrain.colors(64))
#   }
#dev.off()

#postscript(file="vegdrainage2.eps")
#x11()
#fdirPlot(veg[,,90],flowdirns[,,90])
#    #image(topog[,,i],asp=1,xlim=c(0,1),ylim=c(0,1),axes=FALSE,col=terrain.colors(64))
# 
#dev.off()
#library(fields)
#grid.l<-list( abcissa= seq( 1,32,,32), ordinate= seq( 1,32,,32)) 
#xg<-make.surface.grid( grid.l)
#z<- topog[,,-1]
# now fold z in the matrix format needed for persp 
#out.p<-as.surface( xg, z) 
#persp( out.p) 
# also try  plot( out.p)