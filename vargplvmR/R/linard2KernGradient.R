linard2KernGradient <- function (kern, x, ...)
{
# % LINARD2KERNGRADIENT Gradient of LINARD2 kernel's parameters.
# % FORMAT
# % DESC computes the gradient of functions with respect to the
# % automatic relevance determination linear
# % kernel's parameters. As well as the kernel structure and the
# % input positions, the user provides a matrix PARTIAL which gives
# % the partial derivatives of the function with respect to the
# % relevant elements of the kernel matrix. 
# % ARG kern : the kernel structure for which the gradients are being
# % computed.
# % ARG x : the input locations for which the gradients are being
# % computed. 
# % ARG partial : matrix of partial derivatives of the function of
# % interest with respect to the kernel matrix. The argument takes
# % the form of a square matrix of dimension  numData, where numData is
# % the number of rows in X.
# % RETURN g : gradients of the function of interest with respect to
# % the kernel parameters. The ordering of the vector should match
# % that provided by the function kernExtractParam.
# %
# % FORMAT
# % DESC computes the derivatives as above, but input locations are
# % now provided in two matrices associated with rows and columns of
# % the kernel matrix. 
# % ARG kern : the kernel structure for which the gradients are being
# % computed.
# % ARG x1 : the input locations associated with the rows of the
# % kernel matrix.
# % ARG x2 : the input locations associated with the columns of the
# % kernel matrix.
# % ARG partial2 : matrix of partial derivatives of the function of
# % interest with respect to the kernel matrix. The matrix should
# % have the same number of rows as X1 and the same number of columns
# % as X2 has rows.
# % RETURN g : gradients of the function of interest with respect to
# % the kernel parameters.
# %
# % SEEALSO linard2KernParamInit, kernGradient, linard2KernDiagGradient, kernGradX
# %
# % COPYRIGHT : Neil D. Lawrence, 2004, 2005, 2006, 2009
# %
# % COPYRIGHT : Michalis K. Titsias, 2009
  # 
# % KERN
  
  varargin <- list(...)
  g <- matrix(0, 1, dim(x)[2]) 
  if (nargs() < 4)
  {
    k <- linard2KernCompute(kern, x)
  } else {
    k <- linard2KernCompute(kern, x, varargin[[1]])
  }
  
  if (nargs() < 4)
  {
    for (i in 1:dim(x)[2])
      g[i] <-  t(x[,i])%*%varargin[[length(varargin)]]%*%x[, i]
  }
  else {
    cat("linard2KernGradient to do \n")
    for (i in 1:dim(x)[2] )
      g[i] <-  t(x[, i])%*%varargin[[length(varargin)]]%*%varargin[[1]][, i]
  }
  
  return (g)
}