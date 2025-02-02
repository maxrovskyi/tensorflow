// RUN: mlir-hlo-opt %s -verify-diagnostics -allow-unregistered-dialect | FileCheck %s

// Tests for sparse types. Note that most dense MHLO ops can be made sparse
// by simply annotating one or more of the tensor types as sparse. Other than
// subtle printing and parsing difference (due to having different input and
// output types), dense or sparse ops are semantically equivalent.

#CSR = #sparse_tensor.encoding<{
  dimLevelType = ["dense", "compressed"]
}>

#DCSR = #sparse_tensor.encoding<{
  dimLevelType = ["compressed", "compressed"]
}>

//
// Dense unary and binary eltwise. Note that only binary uses custom parser.
//

// CHECK-LABEL: func @dense_abs_eltwise(
//  CHECK-SAME: %[[A:.*]]: tensor<10x20xf32>)
//       CHECK: %[[T:.*]] = "mhlo.abs"(%[[A]]) : (tensor<10x20xf32>) -> tensor<10x20xf32>
//       CHECK: return %[[T]] : tensor<10x20xf32>
func @dense_abs_eltwise(%arg0: tensor<10x20xf32>) -> tensor<10x20xf32> {
  %0 = "mhlo.abs"(%arg0) : (tensor<10x20xf32>) -> tensor<10x20xf32>
  return %0 : tensor<10x20xf32>
}

// CHECK-LABEL: func @dense_add_eltwise(
//  CHECK-SAME: %[[A:.*]]: tensor<10x20xf32>,
//  CHECK-SAME: %[[B:.*]]: tensor<10x20xf32>)
//       CHECK: %[[T:.*]] = mhlo.add %[[A]], %[[B]] : tensor<10x20xf32>
//       CHECK: return %[[T]] : tensor<10x20xf32>
func @dense_add_eltwise(%arg0: tensor<10x20xf32>,
                        %arg1: tensor<10x20xf32>) -> tensor<10x20xf32> {
  %0 = mhlo.add %arg0, %arg1 : tensor<10x20xf32>
  return %0 : tensor<10x20xf32>
}

//
// Sparse unary eltwise.
//

// CHECK-LABEL: func @sparse_abs_eltwise1(
//  CHECK-SAME: %[[A:.*]]: tensor<10x20xf32, #{{.*}}>)
//       CHECK: %[[T:.*]] = "mhlo.abs"(%[[A]]) : (tensor<10x20xf32, #{{.*}}>) -> tensor<10x20xf32>
//       CHECK: return %[[T]] : tensor<10x20xf32>
func @sparse_abs_eltwise1(%arg0: tensor<10x20xf32, #CSR>) -> tensor<10x20xf32> {
  %0 = "mhlo.abs"(%arg0) : (tensor<10x20xf32, #CSR>) -> tensor<10x20xf32>
  return %0 : tensor<10x20xf32>
}

// CHECK-LABEL: func @sparse_abs_eltwise2(
//  CHECK-SAME: %[[A:.*]]: tensor<10x20xf32, #{{.*}}>)
//       CHECK: %[[T:.*]] = "mhlo.abs"(%[[A]]) : (tensor<10x20xf32, #{{.*}}>) -> tensor<10x20xf32, #{{.*}}>
//       CHECK: return %[[T]] : tensor<10x20xf32, #{{.*}}>
func @sparse_abs_eltwise2(%arg0: tensor<10x20xf32, #CSR>) -> tensor<10x20xf32, #CSR> {
  %0 = "mhlo.abs"(%arg0) : (tensor<10x20xf32, #CSR>) -> tensor<10x20xf32, #CSR>
  return %0 : tensor<10x20xf32, #CSR>
}

// CHECK-LABEL: func @sparse_abs_eltwise3(
//  CHECK-SAME: %[[A:.*]]: tensor<10x20xf32, #{{.*}}>)
//       CHECK: %[[T:.*]] = "mhlo.abs"(%[[A]]) : (tensor<10x20xf32, #{{.*}}>) -> tensor<10x20xf32, #{{.*}}>
//       CHECK: return %[[T]] : tensor<10x20xf32, #{{.*}}>
func @sparse_abs_eltwise3(%arg0: tensor<10x20xf32, #CSR>) -> tensor<10x20xf32, #DCSR> {
  %0 = "mhlo.abs"(%arg0) : (tensor<10x20xf32, #CSR>) -> tensor<10x20xf32, #DCSR>
  return %0 : tensor<10x20xf32, #DCSR>
}

// CHECK-LABEL: func @sparse_abs_eltwise4(
//  CHECK-SAME: %[[A:.*]]: tensor<10x20xf32>)
//       CHECK: %[[T:.*]] = "mhlo.abs"(%[[A]]) : (tensor<10x20xf32>) -> tensor<10x20xf32, #{{.*}}>
//       CHECK: return %[[T]] : tensor<10x20xf32, #{{.*}}>
func @sparse_abs_eltwise4(%arg0: tensor<10x20xf32>) -> tensor<10x20xf32, #CSR> {
  %0 = "mhlo.abs"(%arg0) : (tensor<10x20xf32>) -> tensor<10x20xf32, #CSR>
  return %0 : tensor<10x20xf32, #CSR>
}

//
// Sparse binary eltwise.
//

// TODO: sparse binary eltwise
