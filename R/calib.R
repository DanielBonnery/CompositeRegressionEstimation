if(FALSE){
    total=as.vector(dft[list.cal2], "numeric")
q=rep(1,length(df3[,w]))
description=FALSE
max_iter=500

if (any(is.na(Xs)) | any(is.na(d)) | any(is.na(total)) | 
        any(is.na(q))) 
        stop("the input should not contain NAs")
    if (!(is.matrix(Xs) | is.array(Xs))) 
        Xs = as.matrix(Xs)
    if (is.matrix(Xs)) 
        if (length(total) != ncol(Xs)) 
            stop("Xs and total have different dimensions")
    if (is.vector(Xs) & length(total) != 1) 
        stop("Xs and total have different dimensions")
    if (any(is.infinite(q))) 
        stop("there are Inf values in the q vector")
   
    require(MASS)
    EPS = .Machine$double.eps
    EPS1 = 1e-06
    n = length(d)
    lambda = as.matrix(rep(0, n))
    lambda1 = ginv(t(Xs * d * q) %*% Xs, tol = EPS) %*% (total - 
        as.vector(t(d) %*% Xs))
    g = 1 + q * as.vector(Xs %*% lambda1)
    g
}
