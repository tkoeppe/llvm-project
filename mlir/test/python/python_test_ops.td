//===-- python_test_ops.td - Python test Op definitions ----*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef PYTHON_TEST_OPS
#define PYTHON_TEST_OPS

include "mlir/IR/AttrTypeBase.td"
include "mlir/IR/OpBase.td"
include "mlir/Interfaces/InferTypeOpInterface.td"

def Python_Test_Dialect : Dialect {
  let name = "python_test";
  let cppNamespace = "python_test";

  let useDefaultTypePrinterParser = 1;
  let useDefaultAttributePrinterParser = 1;
}

class TestType<string name, string typeMnemonic>
    : TypeDef<Python_Test_Dialect, name> {
  let mnemonic = typeMnemonic;
}

class TestAttr<string name, string attrMnemonic>
    : AttrDef<Python_Test_Dialect, name> {
  let mnemonic = attrMnemonic;
}

class TestOp<string mnemonic, list<Trait> traits = []>
    : Op<Python_Test_Dialect, mnemonic, traits> {
  let assemblyFormat = "operands attr-dict functional-type(operands, results)";
}

//===----------------------------------------------------------------------===//
// Type definitions.
//===----------------------------------------------------------------------===//

def TestType : TestType<"TestType", "test_type">;

//===----------------------------------------------------------------------===//
// Attribute definitions.
//===----------------------------------------------------------------------===//

def TestAttr : TestAttr<"TestAttr", "test_attr">;

//===----------------------------------------------------------------------===//
// Operation definitions.
//===----------------------------------------------------------------------===//

def AttributedOp : TestOp<"attributed_op"> {
  let arguments = (ins I32Attr:$mandatory_i32,
                   OptionalAttr<I32Attr>:$optional_i32,
                   UnitAttr:$unit);
}

def CustomAttributedOp : TestOp<"custom_attributed_op"> {
  let arguments = (ins TestAttr:$test_attr);
}

def AttributesOp : TestOp<"attributes_op"> {
  let arguments = (ins
                   AffineMapArrayAttr:$x_affinemaparr,
                   AffineMapAttr:$x_affinemap,
                   ArrayAttr:$x_arr,
                   BoolArrayAttr:$x_boolarr,
                   BoolAttr:$x_bool,
                   DenseBoolArrayAttr:$x_dboolarr,
                   DenseF32ArrayAttr:$x_df32arr,
                   DenseF64ArrayAttr:$x_df64arr,
                   DenseI16ArrayAttr:$x_df16arr,
                   DenseI32ArrayAttr:$x_di32arr,
                   DenseI64ArrayAttr:$x_di64arr,
                   DenseI8ArrayAttr:$x_di8arr,
                   DictArrayAttr:$x_dictarr,
                   DictionaryAttr:$x_dict,
                   F32ArrayAttr:$x_f32arr,
                   F32Attr:$x_f32,
                   F64ArrayAttr:$x_f64arr,
                   F64Attr:$x_f64,
                   F64ElementsAttr:$x_f64elems,
                   FlatSymbolRefArrayAttr:$x_flatsymrefarr,
                   FlatSymbolRefAttr:$x_flatsymref,
                   I16Attr:$x_i16,
                   I1Attr:$x_i1,
                   I32ArrayAttr:$x_i32arr,
                   I32Attr:$x_i32,
                   I32ElementsAttr:$x_i32elems,
                   I64ArrayAttr:$x_i64arr,
                   I64Attr:$x_i64,
                   I64ElementsAttr:$x_i64elems,
                   I64SmallVectorArrayAttr:$x_i64svecarr,
                   I8Attr:$x_i8,
                   IndexAttr:$x_idx,
                   IndexElementsAttr:$x_idxelems,
                   IndexListArrayAttr:$x_idxlistarr,
                   SI16Attr:$x_si16,
                   SI1Attr:$x_si1,
                   SI32Attr:$x_si32,
                   SI64Attr:$x_si64,
                   SI8Attr:$x_si8,
                   StrArrayAttr:$x_strarr,
                   StrAttr:$x_str,
                   SymbolNameAttr:$x_sym,
                   SymbolRefArrayAttr:$x_symrefarr,
                   SymbolRefAttr:$x_symref,
                   TypeArrayAttr:$x_typearr,
                   TypeAttr:$x_type,
                   UI16Attr:$x_ui16,
                   UI1Attr:$x_ui1,
                   UI32Attr:$x_ui32,
                   UI64Attr:$x_ui64,
                   UI8Attr:$x_ui8,
                   UnitAttr:$x_unit
                   );
}

def PropertyOp : TestOp<"property_op"> {
  let arguments = (ins I32Attr:$property,
                   I32:$idx);
}

def DummyOp : TestOp<"dummy_op"> {
}

def InferResultsOp : TestOp<"infer_results_op", [InferTypeOpInterface]> {
  let arguments = (ins);
  let results = (outs AnyInteger:$single, AnyInteger:$doubled);

  let extraClassDeclaration = [{
    static ::llvm::LogicalResult inferReturnTypes(
      ::mlir::MLIRContext *context, ::std::optional<::mlir::Location> location,
      ::mlir::ValueRange operands, ::mlir::DictionaryAttr attributes,
      ::mlir::OpaqueProperties,
      ::mlir::RegionRange regions,
      ::llvm::SmallVectorImpl<::mlir::Type> &inferredReturnTypes) {
      ::mlir::Builder b(context);
      inferredReturnTypes.push_back(b.getI32Type());
      inferredReturnTypes.push_back(b.getI64Type());
      return ::mlir::success();
    }
  }];
}

def I32OrF32 : TypeConstraint<Or<[I32.predicate, F32.predicate]>,
                                 "i32 or f32">;

def InferResultsVariadicInputsOp : TestOp<"infer_results_variadic_inputs_op",
    [InferTypeOpInterface, AttrSizedOperandSegments]> {
  let arguments = (ins Optional<I64>:$single, Optional<I64>:$doubled);
  let results = (outs I32OrF32:$res);

  let extraClassDeclaration = [{
    static ::llvm::LogicalResult inferReturnTypes(
      ::mlir::MLIRContext *context, ::std::optional<::mlir::Location> location,
      ::mlir::ValueRange operands, ::mlir::DictionaryAttr attributes,
      ::mlir::OpaqueProperties,
      ::mlir::RegionRange regions,
      ::llvm::SmallVectorImpl<::mlir::Type> &inferredReturnTypes) {
      ::mlir::Builder b(context);
      if (operands.size() == 1)
          inferredReturnTypes.push_back(b.getI32Type());
      else if (operands.size() == 2)
          inferredReturnTypes.push_back(b.getF32Type());
      return ::mlir::success();
    }
  }];
}

// If all result types are buildable, the InferTypeOpInterface is implied and is
// autogenerated by C++ ODS.
def InferResultsImpliedOp : TestOp<"infer_results_implied_op"> {
  let results = (outs I32:$integer, F64:$flt, Index:$index);
}

def InferShapedTypeComponentsOp : TestOp<"infer_shaped_type_components_op",
  [DeclareOpInterfaceMethods<InferShapedTypeOpInterface,
                             ["inferReturnTypeComponents"]>]> {
  let arguments = (ins AnyTensor:$operand);
  let results = (outs AnyTensor:$result);

  let extraClassDefinition = [{
    ::llvm::LogicalResult $cppClass::inferReturnTypeComponents(
      ::mlir::MLIRContext *context, ::std::optional<::mlir::Location> location,
      ::mlir::ValueShapeRange operands, ::mlir::DictionaryAttr attributes,
      ::mlir::OpaqueProperties properties, ::mlir::RegionRange regions,
      ::llvm::SmallVectorImpl<
        ::mlir::ShapedTypeComponents>& inferredShapedTypeComponents) {
      $cppClass::Adaptor adaptor(operands, attributes, properties, regions);
      auto operandType =
          ::llvm::cast<::mlir::ShapedType>(adaptor.getOperand().getType());
      if (operandType.hasRank()) {
        inferredShapedTypeComponents.emplace_back(operandType.getShape(),
            operandType.getElementType());
      } else {
        inferredShapedTypeComponents.emplace_back(operandType.getElementType());
      }
      return ::mlir::success();
    }
  }];
}

def SameOperandAndResultTypeOp : TestOp<"same_operand_and_result_type_op",
                                        [SameOperandsAndResultType]> {
  let arguments = (ins Variadic<AnyType>);
  let results = (outs AnyType:$one, AnyType:$two);
}

def FirstAttrDeriveTypeAttrOp : TestOp<"first_attr_derive_type_attr_op",
                               [FirstAttrDerivedResultType]> {
  let arguments = (ins AnyType:$input, TypeAttr:$type);
  let results = (outs AnyType:$one, AnyType:$two);
}

def FirstAttrDeriveAttrOp : TestOp<"first_attr_derive_attr_op",
                               [FirstAttrDerivedResultType]> {
  let arguments = (ins AnyAttr:$iattr);
  let results = (outs AnyType:$one, AnyType:$two, AnyType:$three);
}

def OptionalOperandOp : TestOp<"optional_operand_op"> {
  let arguments = (ins Optional<AnyType>:$input);
  let results = (outs I32:$result);
}

def SameVariadicOperandSizeOp : TestOp<"same_variadic_operand",
                                       [SameVariadicOperandSize]> {
  let arguments = (ins Variadic<AnyType>:$variadic1, AnyType:$non_variadic,
                   Variadic<AnyType>:$variadic2);
}

// Check different arrangements of variadic groups
def SameVariadicResultSizeOpVFV : TestOp<"same_variadic_result_vfv",
                                        [SameVariadicResultSize]> {
  let results = (outs Variadic<AnyType>:$variadic1, AnyType:$non_variadic,
                 Variadic<AnyType>:$variadic2);
}

def SameVariadicResultSizeOpVVV : TestOp<"same_variadic_result_vvv",
                                        [SameVariadicResultSize]> {
  let results = (outs Variadic<AnyType>:$variadic1, Variadic<AnyType>:$variadic2,
                 Variadic<AnyType>:$variadic3);
}

def SameVariadicResultSizeOpFFV : TestOp<"same_variadic_result_ffv",
                                        [SameVariadicResultSize]> {
  let results = (outs AnyType:$non_variadic1, AnyType:$non_variadic2,
                 Variadic<AnyType>:$variadic);
}

def SameVariadicResultSizeOpVVF : TestOp<"same_variadic_result_vvf",
                                        [SameVariadicResultSize]> {
  let results = (outs Variadic<AnyType>:$variadic1, Variadic<AnyType>:$variadic2,
                 AnyType:$non_variadic);
}

def SameVariadicResultSizeOpFVFVF : TestOp<"same_variadic_result_fvfvf",
                                          [SameVariadicResultSize]> {
  let results = (outs AnyType:$non_variadic1, Variadic<AnyType>:$variadic1,
                 AnyType:$non_variadic2, Variadic<AnyType>:$variadic2,
                 AnyType:$non_variadic3);
}

#endif // PYTHON_TEST_OPS
