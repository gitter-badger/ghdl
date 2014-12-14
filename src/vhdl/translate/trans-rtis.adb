--  Iir to ortho translator.
--  Copyright (C) 2002 - 2014 Tristan Gingold
--
--  GHDL is free software; you can redistribute it and/or modify it under
--  the terms of the GNU General Public License as published by the Free
--  Software Foundation; either version 2, or (at your option) any later
--  version.
--
--  GHDL is distributed in the hope that it will be useful, but WITHOUT ANY
--  WARRANTY; without even the implied warranty of MERCHANTABILITY or
--  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
--  for more details.
--
--  You should have received a copy of the GNU General Public License
--  along with GCC; see the file COPYING.  If not, write to the Free
--  Software Foundation, 59 Temple Place - Suite 330, Boston, MA
--  02111-1307, USA.

with Name_Table;
with Files_Map;
with Errorout; use Errorout;
with Iirs_Utils; use Iirs_Utils;
with Configuration;
with Libraries;
with Trans.Chap7;
with Trans.Helpers2; use Trans.Helpers2;

package body Trans.Rtis is

   --  Node for block, generate, processes.
   Ghdl_Rtin_Block           : O_Tnode;
   Ghdl_Rtin_Block_Common    : O_Fnode;
   Ghdl_Rtin_Block_Name      : O_Fnode;
   Ghdl_Rtin_Block_Loc       : O_Fnode;
   Ghdl_Rtin_Block_Linecol   : O_Fnode;
   Ghdl_Rtin_Block_Parent    : O_Fnode;
   Ghdl_Rtin_Block_Size      : O_Fnode;
   Ghdl_Rtin_Block_Nbr_Child : O_Fnode;
   Ghdl_Rtin_Block_Children  : O_Fnode;

   --  A block with a filename: for package, body, entity and architecture.
   Ghdl_Rtin_Block_File : O_Tnode;
   Ghdl_Rtin_Block_File_Block : O_Fnode;
   Ghdl_Rtin_Block_File_Filename : O_Fnode;

   --  Node for scalar type decls.
   Ghdl_Rtin_Type_Scalar        : O_Tnode;
   Ghdl_Rtin_Type_Scalar_Common : O_Fnode;
   Ghdl_Rtin_Type_Scalar_Name   : O_Fnode;

   --  Node for an enumeration type definition.
   Ghdl_Rtin_Type_Enum        : O_Tnode;
   Ghdl_Rtin_Type_Enum_Common : O_Fnode;
   Ghdl_Rtin_Type_Enum_Name   : O_Fnode;
   Ghdl_Rtin_Type_Enum_Nbr    : O_Fnode;
   Ghdl_Rtin_Type_Enum_Lits   : O_Fnode;

   --  Node for an unit64.
   Ghdl_Rtin_Unit64        : O_Tnode;
   Ghdl_Rtin_Unit64_Common : O_Fnode;
   Ghdl_Rtin_Unit64_Name   : O_Fnode;
   Ghdl_Rtin_Unit64_Value  : O_Fnode;

   --  Node for an unitptr.
   Ghdl_Rtin_Unitptr        : O_Tnode;
   Ghdl_Rtin_Unitptr_Common : O_Fnode;
   Ghdl_Rtin_Unitptr_Name   : O_Fnode;
   Ghdl_Rtin_Unitptr_Value  : O_Fnode;

   --  Node for a physical type
   Ghdl_Rtin_Type_Physical        : O_Tnode;
   Ghdl_Rtin_Type_Physical_Common : O_Fnode;
   Ghdl_Rtin_Type_Physical_Name   : O_Fnode;
   Ghdl_Rtin_Type_Physical_Nbr    : O_Fnode;
   Ghdl_Rtin_Type_Physical_Units  : O_Fnode;

   --  Node for a scalar subtype definition.
   Ghdl_Rtin_Subtype_Scalar        : O_Tnode;
   Ghdl_Rtin_Subtype_Scalar_Common : O_Fnode;
   Ghdl_Rtin_Subtype_Scalar_Name   : O_Fnode;
   Ghdl_Rtin_Subtype_Scalar_Base   : O_Fnode;
   Ghdl_Rtin_Subtype_Scalar_Range  : O_Fnode;

   --  Node for an access or a file type.
   Ghdl_Rtin_Type_Fileacc        : O_Tnode;
   Ghdl_Rtin_Type_Fileacc_Common : O_Fnode;
   Ghdl_Rtin_Type_Fileacc_Name   : O_Fnode;
   Ghdl_Rtin_Type_Fileacc_Base   : O_Fnode;

   --  Node for an array type.
   Ghdl_Rtin_Type_Array         : O_Tnode;
   Ghdl_Rtin_Type_Array_Common  : O_Fnode;
   Ghdl_Rtin_Type_Array_Name    : O_Fnode;
   Ghdl_Rtin_Type_Array_Element : O_Fnode;
   Ghdl_Rtin_Type_Array_Nbrdim  : O_Fnode;
   Ghdl_Rtin_Type_Array_Indexes : O_Fnode;

   --  Node for an array subtype.
   Ghdl_Rtin_Subtype_Array          : O_Tnode;
   Ghdl_Rtin_Subtype_Array_Common   : O_Fnode;
   Ghdl_Rtin_Subtype_Array_Name     : O_Fnode;
   Ghdl_Rtin_Subtype_Array_Basetype : O_Fnode;
   Ghdl_Rtin_Subtype_Array_Bounds   : O_Fnode;
   Ghdl_Rtin_Subtype_Array_Valsize  : O_Fnode;
   Ghdl_Rtin_Subtype_Array_Sigsize  : O_Fnode;

   --  Node for a record element.
   Ghdl_Rtin_Element        : O_Tnode;
   Ghdl_Rtin_Element_Common : O_Fnode;
   Ghdl_Rtin_Element_Name   : O_Fnode;
   Ghdl_Rtin_Element_Type   : O_Fnode;
   Ghdl_Rtin_Element_Valoff : O_Fnode;
   Ghdl_Rtin_Element_Sigoff : O_Fnode;

   --  Node for a record type.
   Ghdl_Rtin_Type_Record          : O_Tnode;
   Ghdl_Rtin_Type_Record_Common   : O_Fnode;
   Ghdl_Rtin_Type_Record_Name     : O_Fnode;
   Ghdl_Rtin_Type_Record_Nbrel    : O_Fnode;
   Ghdl_Rtin_Type_Record_Elements : O_Fnode;
   --Ghdl_Rtin_Type_Record_Valsize : O_Fnode;
   --Ghdl_Rtin_Type_Record_Sigsize : O_Fnode;

   --  Node for an object.
   Ghdl_Rtin_Object               : O_Tnode;
   Ghdl_Rtin_Object_Common        : O_Fnode;
   Ghdl_Rtin_Object_Name          : O_Fnode;
   Ghdl_Rtin_Object_Loc           : O_Fnode;
   Ghdl_Rtin_Object_Type          : O_Fnode;
   Ghdl_Rtin_Object_Linecol       : O_Fnode;

   --  Node for an instance.
   Ghdl_Rtin_Instance         : O_Tnode;
   Ghdl_Rtin_Instance_Common  : O_Fnode;
   Ghdl_Rtin_Instance_Name    : O_Fnode;
   Ghdl_Rtin_Instance_Linecol : O_Fnode;
   Ghdl_Rtin_Instance_Loc     : O_Fnode;
   Ghdl_Rtin_Instance_Parent  : O_Fnode;
   Ghdl_Rtin_Instance_Type    : O_Fnode;

   --  Node for a component.
   Ghdl_Rtin_Component           : O_Tnode;
   Ghdl_Rtin_Component_Common    : O_Fnode;
   Ghdl_Rtin_Component_Name      : O_Fnode;
   Ghdl_Rtin_Component_Nbr_Child : O_Fnode;
   Ghdl_Rtin_Component_Children  : O_Fnode;

   procedure Rti_Initialize
   is
   begin
      --  Create type ghdl_rti_kind is (ghdl_rtik_typedef_bool, ...)
      declare
         Constr : O_Enum_List;
      begin
         Start_Enum_Type (Constr, 8);
         New_Enum_Literal
           (Constr, Get_Identifier ("__ghdl_rtik_top"),
            Ghdl_Rtik_Top);
         New_Enum_Literal
           (Constr, Get_Identifier ("__ghdl_rtik_library"),
            Ghdl_Rtik_Library);
         New_Enum_Literal
           (Constr, Get_Identifier ("__ghdl_rtik_package"),
            Ghdl_Rtik_Package);
         New_Enum_Literal
           (Constr, Get_Identifier ("__ghdl_rtik_package_body"),
            Ghdl_Rtik_Package_Body);
         New_Enum_Literal
           (Constr, Get_Identifier ("__ghdl_rtik_entity"),
            Ghdl_Rtik_Entity);
         New_Enum_Literal
           (Constr, Get_Identifier ("__ghdl_rtik_architecture"),
            Ghdl_Rtik_Architecture);
         New_Enum_Literal
           (Constr, Get_Identifier ("__ghdl_rtik_process"),
            Ghdl_Rtik_Process);
         New_Enum_Literal
           (Constr, Get_Identifier ("__ghdl_rtik_block"),
            Ghdl_Rtik_Block);
         New_Enum_Literal
           (Constr, Get_Identifier ("__ghdl_rtik_if_generate"),
            Ghdl_Rtik_If_Generate);
         New_Enum_Literal
           (Constr, Get_Identifier ("__ghdl_rtik_for_generate"),
            Ghdl_Rtik_For_Generate);
         New_Enum_Literal
           (Constr, Get_Identifier ("__ghdl_rtik_instance"),
            Ghdl_Rtik_Instance);

         New_Enum_Literal
           (Constr, Get_Identifier ("__ghdl_rtik_constant"),
            Ghdl_Rtik_Constant);
         New_Enum_Literal
           (Constr, Get_Identifier ("__ghdl_rtik_iterator"),
            Ghdl_Rtik_Iterator);
         New_Enum_Literal
           (Constr, Get_Identifier ("__ghdl_rtik_variable"),
            Ghdl_Rtik_Variable);
         New_Enum_Literal
           (Constr, Get_Identifier ("__ghdl_rtik_signal"),
            Ghdl_Rtik_Signal);
         New_Enum_Literal
           (Constr, Get_Identifier ("__ghdl_rtik_file"),
            Ghdl_Rtik_File);
         New_Enum_Literal
           (Constr, Get_Identifier ("__ghdl_rtik_port"),
            Ghdl_Rtik_Port);
         New_Enum_Literal
           (Constr, Get_Identifier ("__ghdl_rtik_generic"),
            Ghdl_Rtik_Generic);
         New_Enum_Literal
           (Constr, Get_Identifier ("__ghdl_rtik_alias"),
            Ghdl_Rtik_Alias);
         New_Enum_Literal
           (Constr, Get_Identifier ("__ghdl_rtik_guard"),
            Ghdl_Rtik_Guard);
         New_Enum_Literal
           (Constr, Get_Identifier ("__ghdl_rtik_component"),
            Ghdl_Rtik_Component);
         New_Enum_Literal
           (Constr, Get_Identifier ("__ghdl_rtik_attribute"),
            Ghdl_Rtik_Attribute);

         New_Enum_Literal
           (Constr, Get_Identifier ("__ghdl_rtik_type_b1"),
            Ghdl_Rtik_Type_B1);
         New_Enum_Literal
           (Constr, Get_Identifier ("__ghdl_rtik_type_e8"),
            Ghdl_Rtik_Type_E8);
         New_Enum_Literal
           (Constr, Get_Identifier ("__ghdl_rtik_type_e32"),
            Ghdl_Rtik_Type_E32);
         New_Enum_Literal
           (Constr, Get_Identifier ("__ghdl_rtik_type_i32"),
            Ghdl_Rtik_Type_I32);
         New_Enum_Literal
           (Constr, Get_Identifier ("__ghdl_rtik_type_i64"),
            Ghdl_Rtik_Type_I64);
         New_Enum_Literal
           (Constr, Get_Identifier ("__ghdl_rtik_type_f64"),
            Ghdl_Rtik_Type_F64);
         New_Enum_Literal
           (Constr, Get_Identifier ("__ghdl_rtik_type_p32"),
            Ghdl_Rtik_Type_P32);
         New_Enum_Literal
           (Constr, Get_Identifier ("__ghdl_rtik_type_p64"),
            Ghdl_Rtik_Type_P64);
         New_Enum_Literal
           (Constr, Get_Identifier ("__ghdl_rtik_type_access"),
            Ghdl_Rtik_Type_Access);
         New_Enum_Literal
           (Constr, Get_Identifier ("__ghdl_rtik_type_array"),
            Ghdl_Rtik_Type_Array);
         New_Enum_Literal
           (Constr, Get_Identifier ("__ghdl_rtik_type_record"),
            Ghdl_Rtik_Type_Record);
         New_Enum_Literal
           (Constr, Get_Identifier ("__ghdl_rtik_type_file"),
            Ghdl_Rtik_Type_File);
         New_Enum_Literal
           (Constr, Get_Identifier ("__ghdl_rtik_subtype_scalar"),
            Ghdl_Rtik_Subtype_Scalar);
         New_Enum_Literal
           (Constr, Get_Identifier ("__ghdl_rtik_subtype_array"),
            Ghdl_Rtik_Subtype_Array);
         New_Enum_Literal
           (Constr,
            Get_Identifier ("__ghdl_rtik_subtype_unconstrained_array"),
            Ghdl_Rtik_Subtype_Unconstrained_Array);
         New_Enum_Literal
           (Constr, Get_Identifier ("__ghdl_rtik_subtype_record"),
            Ghdl_Rtik_Subtype_Record);
         New_Enum_Literal
           (Constr, Get_Identifier ("__ghdl_rtik_subtype_access"),
            Ghdl_Rtik_Subtype_Access);
         New_Enum_Literal
           (Constr, Get_Identifier ("__ghdl_rtik_type_protected"),
            Ghdl_Rtik_Type_Protected);

         New_Enum_Literal (Constr, Get_Identifier ("__ghdl_rtik_element"),
                           Ghdl_Rtik_Element);
         New_Enum_Literal (Constr, Get_Identifier ("__ghdl_rtik_unit64"),
                           Ghdl_Rtik_Unit64);
         New_Enum_Literal (Constr, Get_Identifier ("__ghdl_rtik_unitptr"),
                           Ghdl_Rtik_Unitptr);

         New_Enum_Literal
           (Constr, Get_Identifier ("__ghdl_rtik_attribute_transaction"),
            Ghdl_Rtik_Attribute_Transaction);
         New_Enum_Literal
           (Constr, Get_Identifier ("__ghdl_rtik_attribute_quiet"),
            Ghdl_Rtik_Attribute_Quiet);
         New_Enum_Literal
           (Constr, Get_Identifier ("__ghdl_rtik_attribute_stable"),
            Ghdl_Rtik_Attribute_Stable);

         New_Enum_Literal
           (Constr, Get_Identifier ("__ghdl_rtik_psl_assert"),
            Ghdl_Rtik_Psl_Assert);

         New_Enum_Literal (Constr, Get_Identifier ("__ghdl_rtik_error"),
                           Ghdl_Rtik_Error);
         Finish_Enum_Type (Constr, Ghdl_Rtik);
         New_Type_Decl (Get_Identifier ("__ghdl_rtik"), Ghdl_Rtik);
      end;

      --  Create type ghdl_rti_depth.
      Ghdl_Rti_Depth := New_Unsigned_Type (8);
      New_Type_Decl (Get_Identifier ("__ghdl_rti_depth"), Ghdl_Rti_Depth);
      Ghdl_Rti_U8 := New_Unsigned_Type (8);
      New_Type_Decl (Get_Identifier ("__ghdl_rti_u8"), Ghdl_Rti_U8);

      --  Create type ghdl_rti_common.
      declare
         Constr : O_Element_List;
      begin
         Start_Record_Type (Constr);
         New_Record_Field (Constr, Ghdl_Rti_Common_Kind,
                           Get_Identifier ("kind"), Ghdl_Rtik);
         New_Record_Field (Constr, Ghdl_Rti_Common_Depth,
                           Get_Identifier ("depth"), Ghdl_Rti_Depth);
         New_Record_Field (Constr, Ghdl_Rti_Common_Mode,
                           Get_Identifier ("mode"), Ghdl_Rti_U8);
         New_Record_Field (Constr, Ghdl_Rti_Common_Max_Depth,
                           Get_Identifier ("max_depth"), Ghdl_Rti_Depth);
         Finish_Record_Type (Constr, Ghdl_Rti_Common);
         New_Type_Decl (Get_Identifier ("__ghdl_rti_common"),
                        Ghdl_Rti_Common);
      end;

      Ghdl_Rti_Access := New_Access_Type (Ghdl_Rti_Common);
      New_Type_Decl (Get_Identifier ("__ghdl_rti_access"), Ghdl_Rti_Access);

      Ghdl_Rti_Array := New_Array_Type (Ghdl_Rti_Access, Ghdl_Index_Type);
      New_Type_Decl (Get_Identifier ("__ghdl_rti_array"), Ghdl_Rti_Array);

      Ghdl_Rti_Arr_Acc := New_Access_Type (Ghdl_Rti_Array);
      New_Type_Decl (Get_Identifier ("__ghdl_rti_arr_acc"),
                     Ghdl_Rti_Arr_Acc);

      --  Ghdl_Component_Link_Type.
      New_Uncomplete_Record_Type (Ghdl_Component_Link_Type);
      New_Type_Decl (Get_Identifier ("__ghdl_component_link_type"),
                     Ghdl_Component_Link_Type);

      Ghdl_Component_Link_Acc := New_Access_Type (Ghdl_Component_Link_Type);
      New_Type_Decl (Get_Identifier ("__ghdl_component_link_acc"),
                     Ghdl_Component_Link_Acc);

      declare
         Constr : O_Element_List;
      begin
         Start_Record_Type (Constr);
         New_Record_Field (Constr, Ghdl_Entity_Link_Rti,
                           Get_Identifier ("rti"), Ghdl_Rti_Access);
         New_Record_Field (Constr, Ghdl_Entity_Link_Parent,
                           Wki_Parent, Ghdl_Component_Link_Acc);
         Finish_Record_Type (Constr, Ghdl_Entity_Link_Type);
         New_Type_Decl (Get_Identifier ("__ghdl_entity_link_type"),
                        Ghdl_Entity_Link_Type);
      end;

      Ghdl_Entity_Link_Acc := New_Access_Type (Ghdl_Entity_Link_Type);
      New_Type_Decl (Get_Identifier ("__ghdl_entity_link_acc"),
                     Ghdl_Entity_Link_Acc);

      declare
         Constr : O_Element_List;
      begin
         Start_Uncomplete_Record_Type (Ghdl_Component_Link_Type, Constr);
         New_Record_Field (Constr, Ghdl_Component_Link_Instance,
                           Wki_Instance, Ghdl_Entity_Link_Acc);
         New_Record_Field (Constr, Ghdl_Component_Link_Stmt,
                           Get_Identifier ("stmt"), Ghdl_Rti_Access);
         Finish_Record_Type (Constr, Ghdl_Component_Link_Type);
      end;

      --  Create type ghdl_rtin_block
      declare
         Constr : O_Element_List;
      begin
         Start_Record_Type (Constr);
         New_Record_Field (Constr, Ghdl_Rtin_Block_Common,
                           Get_Identifier ("common"), Ghdl_Rti_Common);
         New_Record_Field (Constr, Ghdl_Rtin_Block_Name,
                           Get_Identifier ("name"), Char_Ptr_Type);
         New_Record_Field (Constr, Ghdl_Rtin_Block_Loc,
                           Get_Identifier ("loc"), Ghdl_Ptr_Type);
         New_Record_Field (Constr, Ghdl_Rtin_Block_Linecol,
                           Get_Identifier ("linecol"), Ghdl_Index_Type);
         New_Record_Field (Constr, Ghdl_Rtin_Block_Parent,
                           Wki_Parent, Ghdl_Rti_Access);
         New_Record_Field (Constr, Ghdl_Rtin_Block_Size,
                           Get_Identifier ("size"), Ghdl_Index_Type);
         New_Record_Field (Constr, Ghdl_Rtin_Block_Nbr_Child,
                           Get_Identifier ("nbr_child"), Ghdl_Index_Type);
         New_Record_Field (Constr, Ghdl_Rtin_Block_Children,
                           Get_Identifier ("children"), Ghdl_Rti_Arr_Acc);
         Finish_Record_Type (Constr, Ghdl_Rtin_Block);
         New_Type_Decl (Get_Identifier ("__ghdl_rtin_block"),
                        Ghdl_Rtin_Block);
      end;

      --  Create type ghdl_rtin_block_file
      declare
         Constr : O_Element_List;
      begin
         Start_Record_Type (Constr);
         New_Record_Field (Constr, Ghdl_Rtin_Block_File_Block,
                           Get_Identifier ("block"), Ghdl_Rtin_Block);
         New_Record_Field (Constr, Ghdl_Rtin_Block_File_Filename,
                           Get_Identifier ("filename"), Char_Ptr_Type);
         Finish_Record_Type (Constr, Ghdl_Rtin_Block_File);
         New_Type_Decl (Get_Identifier ("__ghdl_rtin_block_file"),
                        Ghdl_Rtin_Block_File);
      end;

      --  type (type and subtype declarations).
      declare
         Constr : O_Element_List;
      begin
         Start_Record_Type (Constr);
         New_Record_Field (Constr, Ghdl_Rtin_Type_Scalar_Common,
                           Get_Identifier ("common"), Ghdl_Rti_Common);
         New_Record_Field (Constr, Ghdl_Rtin_Type_Scalar_Name,
                           Get_Identifier ("name"), Char_Ptr_Type);
         Finish_Record_Type (Constr, Ghdl_Rtin_Type_Scalar);
         New_Type_Decl (Get_Identifier ("__ghdl_rtin_type_scalar"),
                        Ghdl_Rtin_Type_Scalar);
      end;

      --  Type_Enum
      declare
         Constr : O_Element_List;
      begin
         Start_Record_Type (Constr);
         New_Record_Field (Constr, Ghdl_Rtin_Type_Enum_Common,
                           Get_Identifier ("common"), Ghdl_Rti_Common);
         New_Record_Field (Constr, Ghdl_Rtin_Type_Enum_Name,
                           Get_Identifier ("name"), Char_Ptr_Type);
         New_Record_Field (Constr, Ghdl_Rtin_Type_Enum_Nbr,
                           Get_Identifier ("nbr"), Ghdl_Index_Type);
         New_Record_Field (Constr, Ghdl_Rtin_Type_Enum_Lits,
                           Get_Identifier ("lits"),
                           Char_Ptr_Array_Ptr_Type);
         Finish_Record_Type (Constr, Ghdl_Rtin_Type_Enum);
         New_Type_Decl (Get_Identifier ("__ghdl_rtin_type_enum"),
                        Ghdl_Rtin_Type_Enum);
      end;

      --  subtype_scalar
      declare
         Constr : O_Element_List;
      begin
         Start_Record_Type (Constr);
         New_Record_Field (Constr, Ghdl_Rtin_Subtype_Scalar_Common,
                           Get_Identifier ("common"), Ghdl_Rti_Common);
         New_Record_Field (Constr, Ghdl_Rtin_Subtype_Scalar_Name,
                           Get_Identifier ("name"), Char_Ptr_Type);
         New_Record_Field (Constr, Ghdl_Rtin_Subtype_Scalar_Base,
                           Get_Identifier ("base"), Ghdl_Rti_Access);
         New_Record_Field (Constr, Ghdl_Rtin_Subtype_Scalar_Range,
                           Get_Identifier ("range"), Ghdl_Ptr_Type);
         Finish_Record_Type (Constr, Ghdl_Rtin_Subtype_Scalar);
         New_Type_Decl (Get_Identifier ("__ghdl_rtin_subtype_scalar"),
                        Ghdl_Rtin_Subtype_Scalar);
      end;

      --  Unit64
      declare
         Constr : O_Element_List;
      begin
         Start_Record_Type (Constr);
         New_Record_Field (Constr, Ghdl_Rtin_Unit64_Common,
                           Get_Identifier ("common"), Ghdl_Rti_Common);
         New_Record_Field (Constr, Ghdl_Rtin_Unit64_Name,
                           Get_Identifier ("name"), Char_Ptr_Type);
         New_Record_Field (Constr, Ghdl_Rtin_Unit64_Value,
                           Wki_Val, Ghdl_I64_Type);
         Finish_Record_Type (Constr, Ghdl_Rtin_Unit64);
         New_Type_Decl (Get_Identifier ("__ghdl_rtin_unit64"),
                        Ghdl_Rtin_Unit64);
      end;

      --  Unitptr
      declare
         Constr : O_Element_List;
      begin
         Start_Record_Type (Constr);
         New_Record_Field (Constr, Ghdl_Rtin_Unitptr_Common,
                           Get_Identifier ("common"), Ghdl_Rti_Common);
         New_Record_Field (Constr, Ghdl_Rtin_Unitptr_Name,
                           Get_Identifier ("name"), Char_Ptr_Type);
         New_Record_Field (Constr, Ghdl_Rtin_Unitptr_Value,
                           Get_Identifier ("addr"), Ghdl_Ptr_Type);
         Finish_Record_Type (Constr, Ghdl_Rtin_Unitptr);
         New_Type_Decl (Get_Identifier ("__ghdl_rtin_unitptr"),
                        Ghdl_Rtin_Unitptr);
      end;

      --  Physical type.
      declare
         Constr : O_Element_List;
      begin
         Start_Record_Type (Constr);
         New_Record_Field (Constr, Ghdl_Rtin_Type_Physical_Common,
                           Get_Identifier ("common"), Ghdl_Rti_Common);
         New_Record_Field (Constr, Ghdl_Rtin_Type_Physical_Name,
                           Get_Identifier ("name"), Char_Ptr_Type);
         New_Record_Field (Constr, Ghdl_Rtin_Type_Physical_Nbr,
                           Get_Identifier ("nbr"), Ghdl_Index_Type);
         New_Record_Field (Constr, Ghdl_Rtin_Type_Physical_Units,
                           Get_Identifier ("units"), Ghdl_Rti_Arr_Acc);
         Finish_Record_Type (Constr, Ghdl_Rtin_Type_Physical);
         New_Type_Decl (Get_Identifier ("__ghdl_rtin_type_physical"),
                        Ghdl_Rtin_Type_Physical);
      end;

      --  file and access type.
      declare
         Constr : O_Element_List;
      begin
         Start_Record_Type (Constr);
         New_Record_Field (Constr, Ghdl_Rtin_Type_Fileacc_Common,
                           Get_Identifier ("common"), Ghdl_Rti_Common);
         New_Record_Field (Constr, Ghdl_Rtin_Type_Fileacc_Name,
                           Get_Identifier ("name"), Char_Ptr_Type);
         New_Record_Field (Constr, Ghdl_Rtin_Type_Fileacc_Base,
                           Get_Identifier ("base"), Ghdl_Rti_Access);
         Finish_Record_Type (Constr, Ghdl_Rtin_Type_Fileacc);
         New_Type_Decl (Get_Identifier ("__ghdl_rtin_type_fileacc"),
                        Ghdl_Rtin_Type_Fileacc);
      end;

      --  arraytype.
      declare
         Constr : O_Element_List;
      begin
         Start_Record_Type (Constr);
         New_Record_Field (Constr, Ghdl_Rtin_Type_Array_Common,
                           Get_Identifier ("common"), Ghdl_Rti_Common);
         New_Record_Field (Constr, Ghdl_Rtin_Type_Array_Name,
                           Get_Identifier ("name"), Char_Ptr_Type);
         New_Record_Field (Constr, Ghdl_Rtin_Type_Array_Element,
                           Get_Identifier ("element"), Ghdl_Rti_Access);
         New_Record_Field (Constr, Ghdl_Rtin_Type_Array_Nbrdim,
                           Get_Identifier ("nbr_dim"), Ghdl_Index_Type);
         New_Record_Field (Constr, Ghdl_Rtin_Type_Array_Indexes,
                           Get_Identifier ("indexes"), Ghdl_Rti_Arr_Acc);
         Finish_Record_Type (Constr, Ghdl_Rtin_Type_Array);
         New_Type_Decl (Get_Identifier ("__ghdl_rtin_type_array"),
                        Ghdl_Rtin_Type_Array);
      end;

      --  subtype_Array.
      declare
         Constr : O_Element_List;
      begin
         Start_Record_Type (Constr);
         New_Record_Field (Constr, Ghdl_Rtin_Subtype_Array_Common,
                           Get_Identifier ("common"), Ghdl_Rti_Common);
         New_Record_Field (Constr, Ghdl_Rtin_Subtype_Array_Name,
                           Get_Identifier ("name"), Char_Ptr_Type);
         New_Record_Field (Constr, Ghdl_Rtin_Subtype_Array_Basetype,
                           Get_Identifier ("basetype"), Ghdl_Rti_Access);
         New_Record_Field (Constr, Ghdl_Rtin_Subtype_Array_Bounds,
                           Get_Identifier ("bounds"), Ghdl_Ptr_Type);
         New_Record_Field (Constr, Ghdl_Rtin_Subtype_Array_Valsize,
                           Get_Identifier ("val_size"), Ghdl_Ptr_Type);
         New_Record_Field (Constr, Ghdl_Rtin_Subtype_Array_Sigsize,
                           Get_Identifier ("sig_size"), Ghdl_Ptr_Type);
         Finish_Record_Type (Constr, Ghdl_Rtin_Subtype_Array);
         New_Type_Decl (Get_Identifier ("__ghdl_rtin_subtype_array"),
                        Ghdl_Rtin_Subtype_Array);
      end;

      --  type record.
      declare
         Constr : O_Element_List;
      begin
         Start_Record_Type (Constr);
         New_Record_Field (Constr, Ghdl_Rtin_Type_Record_Common,
                           Get_Identifier ("common"), Ghdl_Rti_Common);
         New_Record_Field (Constr, Ghdl_Rtin_Type_Record_Name,
                           Get_Identifier ("name"), Char_Ptr_Type);
         New_Record_Field (Constr, Ghdl_Rtin_Type_Record_Nbrel,
                           Get_Identifier ("nbrel"), Ghdl_Index_Type);
         New_Record_Field (Constr, Ghdl_Rtin_Type_Record_Elements,
                           Get_Identifier ("elements"), Ghdl_Rti_Arr_Acc);
         Finish_Record_Type (Constr, Ghdl_Rtin_Type_Record);
         New_Type_Decl (Get_Identifier ("__ghdl_rtin_type_record"),
                        Ghdl_Rtin_Type_Record);
      end;

      --  record element.
      declare
         Constr : O_Element_List;
      begin
         Start_Record_Type (Constr);
         New_Record_Field (Constr, Ghdl_Rtin_Element_Common,
                           Get_Identifier ("common"), Ghdl_Rti_Common);
         New_Record_Field (Constr, Ghdl_Rtin_Element_Name,
                           Get_Identifier ("name"), Char_Ptr_Type);
         New_Record_Field (Constr, Ghdl_Rtin_Element_Type,
                           Get_Identifier ("eltype"), Ghdl_Rti_Access);
         New_Record_Field (Constr, Ghdl_Rtin_Element_Valoff,
                           Get_Identifier ("val_off"), Ghdl_Index_Type);
         New_Record_Field (Constr, Ghdl_Rtin_Element_Sigoff,
                           Get_Identifier ("sig_off"), Ghdl_Index_Type);
         Finish_Record_Type (Constr, Ghdl_Rtin_Element);
         New_Type_Decl (Get_Identifier ("__ghdl_rtin_element"),
                        Ghdl_Rtin_Element);
      end;

      --  Object.
      declare
         Constr : O_Element_List;
      begin
         Start_Record_Type (Constr);
         New_Record_Field (Constr, Ghdl_Rtin_Object_Common,
                           Get_Identifier ("common"), Ghdl_Rti_Common);
         New_Record_Field (Constr, Ghdl_Rtin_Object_Name,
                           Get_Identifier ("name"), Char_Ptr_Type);
         New_Record_Field (Constr, Ghdl_Rtin_Object_Loc,
                           Get_Identifier ("loc"), Ghdl_Ptr_Type);
         New_Record_Field (Constr, Ghdl_Rtin_Object_Type,
                           Get_Identifier ("obj_type"), Ghdl_Rti_Access);
         New_Record_Field (Constr, Ghdl_Rtin_Object_Linecol,
                           Get_Identifier ("linecol"), Ghdl_Index_Type);
         Finish_Record_Type (Constr, Ghdl_Rtin_Object);
         New_Type_Decl (Get_Identifier ("__ghdl_rtin_object"),
                        Ghdl_Rtin_Object);
      end;

      --  Instance.
      declare
         Constr : O_Element_List;
      begin
         Start_Record_Type (Constr);
         New_Record_Field (Constr, Ghdl_Rtin_Instance_Common,
                           Get_Identifier ("common"), Ghdl_Rti_Common);
         New_Record_Field (Constr, Ghdl_Rtin_Instance_Name,
                           Get_Identifier ("name"), Char_Ptr_Type);
         New_Record_Field (Constr, Ghdl_Rtin_Instance_Linecol,
                           Get_Identifier ("linecol"), Ghdl_Index_Type);
         New_Record_Field (Constr, Ghdl_Rtin_Instance_Loc,
                           Get_Identifier ("loc"), Ghdl_Ptr_Type);
         New_Record_Field (Constr, Ghdl_Rtin_Instance_Parent,
                           Wki_Parent, Ghdl_Rti_Access);
         New_Record_Field (Constr, Ghdl_Rtin_Instance_Type,
                           Get_Identifier ("instance"), Ghdl_Rti_Access);
         Finish_Record_Type (Constr, Ghdl_Rtin_Instance);
         New_Type_Decl (Get_Identifier ("__ghdl_rtin_instance"),
                        Ghdl_Rtin_Instance);
      end;

      --  Component
      declare
         Constr : O_Element_List;
      begin
         Start_Record_Type (Constr);
         New_Record_Field (Constr, Ghdl_Rtin_Component_Common,
                           Get_Identifier ("common"), Ghdl_Rti_Common);
         New_Record_Field (Constr, Ghdl_Rtin_Component_Name,
                           Get_Identifier ("name"), Char_Ptr_Type);
         New_Record_Field (Constr, Ghdl_Rtin_Component_Nbr_Child,
                           Get_Identifier ("nbr_child"), Ghdl_Index_Type);
         New_Record_Field (Constr, Ghdl_Rtin_Component_Children,
                           Get_Identifier ("children"), Ghdl_Rti_Arr_Acc);
         Finish_Record_Type (Constr, Ghdl_Rtin_Component);
         New_Type_Decl (Get_Identifier ("__ghdl_rtin_component"),
                        Ghdl_Rtin_Component);
      end;

   end Rti_Initialize;

   type Rti_Array is array (1 .. 8) of O_Dnode;
   type Rti_Array_List;
   type Rti_Array_List_Acc is access Rti_Array_List;
   type Rti_Array_List is record
      Rtis : Rti_Array;
      Next : Rti_Array_List_Acc;
   end record;

   type Rti_Block is record
      Depth     : Rti_Depth_Type;
      Nbr       : Integer;
      List      : Rti_Array_List;
      Last_List : Rti_Array_List_Acc;
      Last_Nbr  : Integer;
   end record;

   Cur_Block : Rti_Block := (Depth => 0,
                             Nbr => 0,
                             List => (Rtis => (others => O_Dnode_Null),
                                      Next => null),
                             Last_List => null,
                             Last_Nbr => 0);

   Free_List : Rti_Array_List_Acc := null;

   procedure Push_Rti_Node (Prev : out Rti_Block; Deeper : Boolean := True)
   is
      Ndepth : Rti_Depth_Type;
   begin
      if Deeper then
         Ndepth := Cur_Block.Depth + 1;
      else
         Ndepth := Cur_Block.Depth;
      end if;
      Prev := Cur_Block;
      Cur_Block := (Depth => Ndepth,
                    Nbr => 0,
                    List => (Rtis => (others => O_Dnode_Null),
                             Next => null),
                    Last_List => null,
                    Last_Nbr => 0);
   end Push_Rti_Node;

   procedure Add_Rti_Node (Node : O_Dnode)
   is
   begin
      if Node = O_Dnode_Null then
         --  FIXME: temporary for not yet handled types.
         return;
      end if;
      if Cur_Block.Last_Nbr = Rti_Array'Last then
         declare
            N : Rti_Array_List_Acc;
         begin
            if Free_List = null then
               N := new Rti_Array_List;
            else
               N := Free_List;
               Free_List := N.Next;
            end if;
            N.Next := null;
            if Cur_Block.Last_List = null then
               Cur_Block.List.Next := N;
            else
               Cur_Block.Last_List.Next := N;
            end if;
            Cur_Block.Last_List := N;
         end;
         Cur_Block.Last_Nbr := 1;
      else
         Cur_Block.Last_Nbr := Cur_Block.Last_Nbr + 1;
      end if;
      if Cur_Block.Last_List = null then
         Cur_Block.List.Rtis (Cur_Block.Last_Nbr) := Node;
      else
         Cur_Block.Last_List.Rtis (Cur_Block.Last_Nbr) := Node;
      end if;
      Cur_Block.Nbr := Cur_Block.Nbr + 1;
   end Add_Rti_Node;

   function Generate_Rti_Array (Id : O_Ident) return O_Dnode
   is
      Arr_Type : O_Tnode;
      List     : O_Array_Aggr_List;
      L        : Rti_Array_List_Acc;
      Nbr      : Integer;
      Val      : O_Cnode;
      Res      : O_Dnode;
   begin
      Arr_Type := New_Constrained_Array_Type
        (Ghdl_Rti_Array,
         New_Unsigned_Literal (Ghdl_Index_Type,
           Unsigned_64 (Cur_Block.Nbr + 1)));
      New_Const_Decl (Res, Id, O_Storage_Private, Arr_Type);
      Start_Const_Value (Res);
      Start_Array_Aggr (List, Arr_Type);
      Nbr := Cur_Block.Nbr;
      for I in Cur_Block.List.Rtis'Range loop
         exit when I > Nbr;
         New_Array_Aggr_El
           (List, New_Global_Unchecked_Address (Cur_Block.List.Rtis (I),
            Ghdl_Rti_Access));
      end loop;
      L := Cur_Block.List.Next;
      while L /= null loop
         Nbr := Nbr - Cur_Block.List.Rtis'Length;
         for I in L.Rtis'Range loop
            exit when I > Nbr;
            New_Array_Aggr_El
              (List, New_Global_Unchecked_Address (L.Rtis (I),
               Ghdl_Rti_Access));
         end loop;
         L := L.Next;
      end loop;
      New_Array_Aggr_El (List, New_Null_Access (Ghdl_Rti_Access));
      Finish_Array_Aggr (List, Val);
      Finish_Const_Value (Res, Val);
      return Res;
   end Generate_Rti_Array;

   procedure Pop_Rti_Node (Prev : Rti_Block)
   is
      L : Rti_Array_List_Acc;
   begin
      L := Cur_Block.List.Next;
      if L /= null then
         Cur_Block.Last_List.Next := Free_List;
         Free_List := Cur_Block.List.Next;
         Cur_Block.List.Next := null;
      end if;
      Cur_Block := Prev;
   end Pop_Rti_Node;

   function Get_Depth_From_Var (Var : Var_Type) return Rti_Depth_Type
   is
   begin
      if Var = Null_Var or else Is_Var_Field (Var) then
         return Cur_Block.Depth;
      else
         return 0;
      end if;
   end Get_Depth_From_Var;

   function Generate_Common
     (Kind : O_Cnode; Var : Var_Type := Null_Var; Mode : Natural := 0)
     return O_Cnode
   is
      List : O_Record_Aggr_List;
      Res  : O_Cnode;
      Val  : Unsigned_64;
   begin
      Start_Record_Aggr (List, Ghdl_Rti_Common);
      New_Record_Aggr_El (List, Kind);
      Val := Unsigned_64 (Get_Depth_From_Var (Var));
      New_Record_Aggr_El (List, New_Unsigned_Literal (Ghdl_Rti_Depth, Val));
      New_Record_Aggr_El
        (List, New_Unsigned_Literal (Ghdl_Rti_U8, Unsigned_64 (Mode)));
      New_Record_Aggr_El (List, New_Unsigned_Literal (Ghdl_Rti_Depth, 0));
      Finish_Record_Aggr (List, Res);
      return Res;
   end Generate_Common;

   --  Same as Generat_Common but for types.
   function Generate_Common_Type (Kind : O_Cnode;
                                  Depth : Rti_Depth_Type;
                                  Max_Depth : Rti_Depth_Type;
                                  Mode : Natural := 0)
                                 return O_Cnode
   is
      List : O_Record_Aggr_List;
      Res  : O_Cnode;
   begin
      Start_Record_Aggr (List, Ghdl_Rti_Common);
      New_Record_Aggr_El (List, Kind);
      New_Record_Aggr_El
        (List,
         New_Unsigned_Literal (Ghdl_Rti_Depth, Unsigned_64 (Depth)));
      New_Record_Aggr_El
        (List, New_Unsigned_Literal (Ghdl_Rti_U8, Unsigned_64 (Mode)));
      New_Record_Aggr_El
        (List,
         New_Unsigned_Literal (Ghdl_Rti_Depth, Unsigned_64 (Max_Depth)));
      Finish_Record_Aggr (List, Res);
      return Res;
   end Generate_Common_Type;

   function Generate_Name (Node : Iir) return O_Dnode
   is
      use Name_Table;
      Id : Name_Id;
   begin
      Id := Get_Identifier (Node);
      if Is_Character (Id) then
         Name_Buffer (1) := ''';
         Name_Buffer (2) := Get_Character (Id);
         Name_Buffer (3) := ''';
         Name_Length := 3;
      else
         Image (Id);
      end if;
      return Create_String (Name_Buffer (1 .. Name_Length),
                            Create_Identifier ("RTISTR"));
   end Generate_Name;

   function Get_Null_Loc return O_Cnode is
   begin
      return New_Null_Access (Ghdl_Ptr_Type);
   end Get_Null_Loc;

   function Var_Acc_To_Loc (Var : Var_Type) return O_Cnode
   is
   begin
      if Is_Var_Field (Var) then
         return Get_Var_Offset (Var, Ghdl_Ptr_Type);
      else
         return New_Global_Unchecked_Address (Get_Var_Label (Var),
                                              Ghdl_Ptr_Type);
      end if;
   end Var_Acc_To_Loc;

   --  Generate a name constant for the name of type definition DEF.
   --  If DEF is an anonymous subtype, returns O_LNODE_NULL.
   --  Use function NEW_NAME_ADDRESS (defined below) to convert the
   --  result into an address expression.
   function Generate_Type_Name (Def : Iir) return O_Dnode
   is
      Decl : Iir;
   begin
      Decl := Get_Type_Declarator (Def);
      if Decl /= Null_Iir then
         return Generate_Name (Decl);
      else
         return O_Dnode_Null;
      end if;
   end Generate_Type_Name;

   --  Convert a name constant NAME into an address.
   --  If NAME is O_LNODE_NULL, return a null address.
   --  To be used with GENERATE_TYPE_NAME.
   function New_Name_Address (Name : O_Dnode) return O_Cnode
   is
   begin
      if Name = O_Dnode_Null then
         return New_Null_Access (Char_Ptr_Type);
      else
         return New_Global_Unchecked_Address (Name, Char_Ptr_Type);
      end if;
   end New_Name_Address;

   function New_Rti_Address (Rti : O_Dnode) return O_Cnode is
   begin
      return New_Global_Unchecked_Address (Rti, Ghdl_Rti_Access);
   end New_Rti_Address;

   --  Declare the RTI constant for type definition attached to INFO.
   --  The only feature is not to declare it if it was already declared.
   --  (due to an incomplete type declaration).
   procedure Generate_Type_Rti (Info : Type_Info_Acc; Rti_Type : O_Tnode)
   is
   begin
      if Info.Type_Rti = O_Dnode_Null then
         New_Const_Decl (Info.Type_Rti, Create_Identifier ("RTI"),
                         Global_Storage, Rti_Type);
      end if;
   end Generate_Type_Rti;

   function Generate_Type_Definition (Atype : Iir; Force : Boolean := False)
                                         return O_Dnode;

   procedure Generate_Enumeration_Type_Definition (Atype : Iir)
   is
      Info : constant Type_Info_Acc := Get_Info (Atype);
      Val  : O_Cnode;
   begin
      Generate_Type_Rti (Info, Ghdl_Rtin_Type_Enum);
      Info.T.Rti_Max_Depth := 0;

      if Global_Storage = O_Storage_External then
         return;
      end if;

      declare
         Lit_List : constant Iir_List :=
           Get_Enumeration_Literal_List (Atype);
         Nbr_Lit  : constant Integer := Get_Nbr_Elements (Lit_List);
         Lit      : Iir;

         type Dnode_Array is array (Natural range <>) of O_Dnode;
         Name_Lits : Dnode_Array (0 .. Nbr_Lit - 1);
         Mark : Id_Mark_Type;
         Name_Arr_Type : O_Tnode;
         Name_Arr : O_Dnode;

         Arr_Aggr : O_Array_Aggr_List;
         Rec_Aggr : O_Record_Aggr_List;
         Kind     : O_Cnode;
         Name     : O_Dnode;
      begin
         --  Generate name for each literal.
         for I in Name_Lits'Range loop
            Lit := Get_Nth_Element (Lit_List, I);
            Push_Identifier_Prefix (Mark, Get_Identifier (Lit));
            Name_Lits (I) := Generate_Name (Lit);
            Pop_Identifier_Prefix (Mark);
         end loop;

         --  Generate array of names.
         Name_Arr_Type := New_Constrained_Array_Type
           (Char_Ptr_Array_Type,
            New_Unsigned_Literal (Ghdl_Index_Type,
              Unsigned_64 (Nbr_Lit)));
         New_Const_Decl (Name_Arr, Create_Identifier ("RTINAMES"),
                         O_Storage_Private, Name_Arr_Type);
         Start_Const_Value (Name_Arr);
         Start_Array_Aggr (Arr_Aggr, Name_Arr_Type);
         for I in Name_Lits'Range loop
            New_Array_Aggr_El
              (Arr_Aggr, New_Global_Address (Name_Lits (I), Char_Ptr_Type));
         end loop;
         Finish_Array_Aggr (Arr_Aggr, Val);
         Finish_Const_Value (Name_Arr, Val);

         Name := Generate_Type_Name (Atype);

         Start_Const_Value (Info.Type_Rti);
         case Info.Type_Mode is
            when Type_Mode_B1 =>
               Kind := Ghdl_Rtik_Type_B1;
            when Type_Mode_E8 =>
               Kind := Ghdl_Rtik_Type_E8;
            when Type_Mode_E32 =>
               Kind := Ghdl_Rtik_Type_E32;
            when others =>
               raise Internal_Error;
         end case;
         Start_Record_Aggr (Rec_Aggr, Ghdl_Rtin_Type_Enum);
         New_Record_Aggr_El (Rec_Aggr, Generate_Common_Type (Kind, 0, 0));
         New_Record_Aggr_El (Rec_Aggr, New_Name_Address (Name));
         New_Record_Aggr_El
           (Rec_Aggr, New_Unsigned_Literal (Ghdl_Index_Type,
            Unsigned_64 (Nbr_Lit)));
         New_Record_Aggr_El
           (Rec_Aggr,
            New_Global_Address (Name_Arr, Char_Ptr_Array_Ptr_Type));
         Finish_Record_Aggr (Rec_Aggr, Val);
         Finish_Const_Value (Info.Type_Rti, Val);
      end;
   end Generate_Enumeration_Type_Definition;

   procedure Generate_Scalar_Type_Definition (Atype : Iir; Name : O_Dnode)
   is
      Info : Type_Info_Acc;
      Kind : O_Cnode;
      Val  : O_Cnode;
      List : O_Record_Aggr_List;
   begin
      Info := Get_Info (Atype);

      Generate_Type_Rti (Info, Ghdl_Rtin_Type_Scalar);
      Info.T.Rti_Max_Depth := 0;

      if Global_Storage = O_Storage_External then
         return;
      end if;

      Start_Const_Value (Info.Type_Rti);
      case Info.Type_Mode is
         when Type_Mode_I32 =>
            Kind := Ghdl_Rtik_Type_I32;
         when Type_Mode_I64 =>
            Kind := Ghdl_Rtik_Type_I64;
         when Type_Mode_F64 =>
            Kind := Ghdl_Rtik_Type_F64;
         when Type_Mode_P64 =>
            Kind := Ghdl_Rtik_Type_P64;
         when others =>
            Error_Kind ("generate_scalar_type_definition", Atype);
      end case;
      Start_Record_Aggr (List, Ghdl_Rtin_Type_Scalar);
      New_Record_Aggr_El (List, Generate_Common_Type (Kind, 0, 0));
      New_Record_Aggr_El (List, New_Name_Address (Name));
      Finish_Record_Aggr (List, Val);
      Finish_Const_Value (Info.Type_Rti, Val);
   end Generate_Scalar_Type_Definition;

   procedure Generate_Unit_Declaration (Unit : Iir_Unit_Declaration)
   is
      Name     : O_Dnode;
      Mark     : Id_Mark_Type;
      Aggr     : O_Record_Aggr_List;
      Val      : O_Cnode;
      Const    : O_Dnode;
      Info     : constant Object_Info_Acc := Get_Info (Unit);
      Rti_Type : O_Tnode;
      Rtik     : O_Cnode;
   begin
      Push_Identifier_Prefix (Mark, Get_Identifier (Unit));
      Name := Generate_Name (Unit);
      if Info /= null then
         --  Non-static units.  The only possibility is a unit of
         --  std.standard.time.
         Rti_Type := Ghdl_Rtin_Unitptr;
         Rtik := Ghdl_Rtik_Unitptr;
      else
         Rti_Type := Ghdl_Rtin_Unit64;
         Rtik := Ghdl_Rtik_Unit64;
      end if;
      New_Const_Decl (Const, Create_Identifier ("RTI"),
                      Global_Storage, Rti_Type);
      Start_Const_Value (Const);
      Start_Record_Aggr (Aggr, Rti_Type);
      New_Record_Aggr_El (Aggr, Generate_Common (Rtik));
      New_Record_Aggr_El (Aggr, New_Name_Address (Name));
      if Info /= null then
         --  Handle non-static units.  The only possibility is a unit of
         --  std.standard.time.
         Val := New_Global_Unchecked_Address
           (Get_Var_Label (Info.Object_Var), Ghdl_Ptr_Type);
      else
         Val := Chap7.Translate_Numeric_Literal (Unit, Ghdl_I64_Type);
      end if;
      New_Record_Aggr_El (Aggr, Val);
      Finish_Record_Aggr (Aggr, Val);
      Finish_Const_Value (Const, Val);
      Add_Rti_Node (Const);
      Pop_Identifier_Prefix (Mark);
   end Generate_Unit_Declaration;

   procedure Generate_Physical_Type_Definition (Atype : Iir; Name : O_Dnode)
   is
      Info      : Type_Info_Acc;
      Val       : O_Cnode;
      List      : O_Record_Aggr_List;
      Prev      : Rti_Block;
      Unit      : Iir_Unit_Declaration;
      Nbr_Units : Integer;
      Unit_Arr  : O_Dnode;
      Rti_Kind  : O_Cnode;
   begin
      Info := Get_Info (Atype);

      Generate_Type_Rti (Info, Ghdl_Rtin_Type_Physical);

      if Global_Storage = O_Storage_External then
         return;
      end if;

      Push_Rti_Node (Prev, False);
      Unit := Get_Unit_Chain (Atype);
      Nbr_Units := 0;
      while Unit /= Null_Iir loop
         Generate_Unit_Declaration (Unit);
         Nbr_Units := Nbr_Units + 1;
         Unit := Get_Chain (Unit);
      end loop;
      Unit_Arr := Generate_Rti_Array (Create_Identifier ("RTIARRAY"));
      Pop_Rti_Node (Prev);

      Start_Const_Value (Info.Type_Rti);
      Start_Record_Aggr (List, Ghdl_Rtin_Type_Physical);
      case Info.Type_Mode is
         when Type_Mode_P64 =>
            Rti_Kind := Ghdl_Rtik_Type_P64;
         when Type_Mode_P32 =>
            Rti_Kind := Ghdl_Rtik_Type_P32;
         when others =>
            raise Internal_Error;
      end case;
      New_Record_Aggr_El (List, Generate_Common_Type (Rti_Kind, 0, 0, 0));
      New_Record_Aggr_El (List, New_Name_Address (Name));
      New_Record_Aggr_El
        (List,
         New_Unsigned_Literal (Ghdl_Index_Type,
           Unsigned_64 (Nbr_Units)));
      New_Record_Aggr_El
        (List, New_Global_Address (Unit_Arr, Ghdl_Rti_Arr_Acc));
      Finish_Record_Aggr (List, Val);
      Finish_Const_Value (Info.Type_Rti, Val);
   end Generate_Physical_Type_Definition;

   procedure Generate_Scalar_Subtype_Definition (Atype : Iir)
   is
      Base_Type : Iir;
      Base_Info : Type_Info_Acc;
      Info      : Type_Info_Acc;
      Aggr      : O_Record_Aggr_List;
      Val       : O_Cnode;
      Name      : O_Dnode;
   begin
      Info := Get_Info (Atype);

      if Global_Storage = O_Storage_External then
         Name := O_Dnode_Null;
      else
         Name := Generate_Type_Name (Atype);
      end if;

      --  Generate base type definition, if necessary.
      --  (do it even in packages).
      Base_Type := Get_Base_Type (Atype);
      Base_Info := Get_Info (Base_Type);
      if Base_Info.Type_Rti = O_Dnode_Null then
         declare
            Mark : Id_Mark_Type;
         begin
            Push_Identifier_Prefix (Mark, "BT");
            if Get_Kind (Base_Type) = Iir_Kind_Physical_Type_Definition then
               Generate_Physical_Type_Definition (Base_Type, Name);
            else
               Generate_Scalar_Type_Definition (Base_Type, Name);
            end if;
            Pop_Identifier_Prefix (Mark);
         end;
      end if;

      Generate_Type_Rti (Info, Ghdl_Rtin_Subtype_Scalar);
      Info.T.Rti_Max_Depth := Get_Depth_From_Var (Info.T.Range_Var);
      if Global_Storage = O_Storage_External then
         return;
      end if;

      Start_Const_Value (Info.Type_Rti);
      Start_Record_Aggr (Aggr, Ghdl_Rtin_Subtype_Scalar);
      New_Record_Aggr_El
        (Aggr, Generate_Common_Type (Ghdl_Rtik_Subtype_Scalar,
         Info.T.Rti_Max_Depth,
         Info.T.Rti_Max_Depth));

      New_Record_Aggr_El (Aggr, New_Name_Address (Name));
      New_Record_Aggr_El (Aggr, New_Rti_Address (Base_Info.Type_Rti));
      New_Record_Aggr_El (Aggr, Var_Acc_To_Loc (Info.T.Range_Var));
      Finish_Record_Aggr (Aggr, Val);
      Finish_Const_Value (Info.Type_Rti, Val);
   end Generate_Scalar_Subtype_Definition;

   procedure Generate_Fileacc_Type_Definition (Atype : Iir)
   is
      Info      : Type_Info_Acc;
      Kind      : O_Cnode;
      Val       : O_Cnode;
      List      : O_Record_Aggr_List;
      Name      : O_Dnode;
      Base      : O_Dnode;
      Base_Type : Iir;
   begin
      Info := Get_Info (Atype);

      Generate_Type_Rti (Info, Ghdl_Rtin_Type_Fileacc);

      if Global_Storage = O_Storage_External then
         return;
      end if;

      case Get_Kind (Atype) is
         when Iir_Kind_Access_Type_Definition =>
            declare
               Mark : Id_Mark_Type;
            begin
               Push_Identifier_Prefix (Mark, "AT");
               Base := Generate_Type_Definition
                 (Get_Designated_Type (Atype));
               Pop_Identifier_Prefix (Mark);
            end;
            if Get_Kind (Atype) = Iir_Kind_Access_Subtype_Definition then
               Kind := Ghdl_Rtik_Subtype_Access;
            else
               Kind := Ghdl_Rtik_Type_Access;
            end if;
            --  Don't bother with designated type.  This at least avoid
            --  loops.
            Base_Type := Null_Iir;
         when Iir_Kind_File_Type_Definition =>
            Base_Type := Get_Type (Get_File_Type_Mark (Atype));
            Base := Generate_Type_Definition (Base_Type);
            Kind := Ghdl_Rtik_Type_File;
         when Iir_Kind_Record_Subtype_Definition =>
            Base_Type := Get_Base_Type (Atype);
            Base := Get_Info (Base_Type).Type_Rti;
            Kind := Ghdl_Rtik_Subtype_Record;
         when Iir_Kind_Access_Subtype_Definition =>
            Base_Type := Get_Base_Type (Atype);
            Base := Get_Info (Base_Type).Type_Rti;
            Kind := Ghdl_Rtik_Subtype_Access;
         when others =>
            Error_Kind ("rti.generate_fileacc_type_definition", Atype);
      end case;
      if Base_Type = Null_Iir then
         Info.T.Rti_Max_Depth := 0;
      else
         Info.T.Rti_Max_Depth := Get_Info (Base_Type).T.Rti_Max_Depth;
      end if;
      Name := Generate_Type_Name (Atype);

      Start_Const_Value (Info.Type_Rti);
      Start_Record_Aggr (List, Ghdl_Rtin_Type_Fileacc);
      New_Record_Aggr_El
        (List, Generate_Common_Type (Kind, 0, Info.T.Rti_Max_Depth));
      New_Record_Aggr_El (List, New_Name_Address (Name));
      New_Record_Aggr_El (List, New_Rti_Address (Base));
      Finish_Record_Aggr (List, Val);
      Finish_Const_Value (Info.Type_Rti, Val);
   end Generate_Fileacc_Type_Definition;

   procedure Generate_Array_Type_Indexes
     (Atype : Iir; Res : out O_Dnode; Max_Depth : in out Rti_Depth_Type)
   is
      List        : constant Iir_List := Get_Index_Subtype_List (Atype);
      Nbr_Indexes : constant Natural := Get_Nbr_Elements (List);
      Index       : Iir;
      Tmp         : O_Dnode;
      pragma Unreferenced (Tmp);
      Arr_Type    : O_Tnode;
      Arr_Aggr    : O_Array_Aggr_List;
      Val         : O_Cnode;
      Mark        : Id_Mark_Type;
   begin
      --  Translate each index.
      for I in 1 .. Nbr_Indexes loop
         Index := Get_Index_Type (List, I - 1);
         Push_Identifier_Prefix (Mark, "DIM", Iir_Int32 (I));
         Tmp := Generate_Type_Definition (Index);
         Max_Depth := Rti_Depth_Type'Max (Max_Depth,
                                          Get_Info (Index).T.Rti_Max_Depth);
         Pop_Identifier_Prefix (Mark);
      end loop;

      --  Generate array of index.
      Arr_Type := New_Constrained_Array_Type
        (Ghdl_Rti_Array,
         New_Unsigned_Literal (Ghdl_Index_Type, Unsigned_64 (Nbr_Indexes)));
      New_Const_Decl (Res, Create_Identifier ("RTIINDEXES"),
                      Global_Storage, Arr_Type);
      Start_Const_Value (Res);

      Start_Array_Aggr (Arr_Aggr, Arr_Type);
      for I in 1 .. Nbr_Indexes loop
         Index := Get_Index_Type (List, I - 1);
         New_Array_Aggr_El
           (Arr_Aggr, New_Rti_Address (Generate_Type_Definition (Index)));
      end loop;
      Finish_Array_Aggr (Arr_Aggr, Val);
      Finish_Const_Value (Res, Val);
   end Generate_Array_Type_Indexes;

   function Type_To_Mode (Atype : Iir) return Natural is
      Res : Natural := 0;
   begin
      if Is_Complex_Type (Get_Info (Atype)) then
         Res := Res + 1;
      end if;
      if Is_Anonymous_Type_Definition (Atype)
        or else (Get_Kind (Get_Type_Declarator (Atype))
                 = Iir_Kind_Anonymous_Type_Declaration)
      then
         Res := Res + 2;
      end if;
      return Res;
   end Type_To_Mode;

   procedure Generate_Array_Type_Definition
     (Atype : Iir_Array_Type_Definition)
   is
      Info      : Type_Info_Acc;
      Aggr      : O_Record_Aggr_List;
      Val       : O_Cnode;
      List      : Iir_List;
      Arr       : O_Dnode;
      Element   : Iir;
      Name      : O_Dnode;
      El_Info   : Type_Info_Acc;
      Max_Depth : Rti_Depth_Type;
   begin
      Info := Get_Info (Atype);

      Generate_Type_Rti (Info, Ghdl_Rtin_Type_Array);

      if Global_Storage = O_Storage_External then
         return;
      end if;

      Name := Generate_Type_Name (Atype);
      Element := Get_Element_Subtype (Atype);
      El_Info := Get_Info (Element);
      if El_Info.Type_Rti = O_Dnode_Null then
         declare
            Mark   : Id_Mark_Type;
            El_Rti : O_Dnode;
            pragma Unreferenced (El_Rti);
         begin
            Push_Identifier_Prefix (Mark, "EL");
            El_Rti := Generate_Type_Definition (Element);
            Pop_Identifier_Prefix (Mark);
         end;
      end if;
      Max_Depth := El_Info.T.Rti_Max_Depth;

      --  Translate each index.
      Generate_Array_Type_Indexes (Atype, Arr, Max_Depth);
      Info.T.Rti_Max_Depth := Max_Depth;
      List := Get_Index_Subtype_List (Atype);

      --  Generate node.
      Start_Const_Value (Info.Type_Rti);
      Start_Record_Aggr (Aggr, Ghdl_Rtin_Type_Array);
      New_Record_Aggr_El
        (Aggr,
         Generate_Common_Type
           (Ghdl_Rtik_Type_Array, 0, Max_Depth, Type_To_Mode (Atype)));
      New_Record_Aggr_El (Aggr, New_Name_Address (Name));
      New_Record_Aggr_El (Aggr, New_Rti_Address (El_Info.Type_Rti));
      New_Record_Aggr_El
        (Aggr,
         New_Unsigned_Literal (Ghdl_Index_Type,
           Unsigned_64 (Get_Nbr_Elements (List))));
      New_Record_Aggr_El (Aggr, New_Global_Address (Arr, Ghdl_Rti_Arr_Acc));
      Finish_Record_Aggr (Aggr, Val);
      Finish_Const_Value (Info.Type_Rti, Val);
   end Generate_Array_Type_Definition;

   procedure Generate_Array_Subtype_Definition
     (Atype : Iir_Array_Subtype_Definition)
   is
      Base_Type : Iir;
      Base_Info : Type_Info_Acc;
      Info      : Type_Info_Acc;
      Aggr      : O_Record_Aggr_List;
      Val       : O_Cnode;
      Base_Rti  : O_Dnode;
      pragma Unreferenced (Base_Rti);
      Bounds    : Var_Type;
      Name      : O_Dnode;
      Kind      : O_Cnode;
      Mark      : Id_Mark_Type;
      Depth     : Rti_Depth_Type;
   begin
      --  FIXME: temporary work-around
      if Get_Constraint_State (Atype) /= Fully_Constrained then
         return;
      end if;

      Info := Get_Info (Atype);

      Base_Type := Get_Base_Type (Atype);
      Base_Info := Get_Info (Base_Type);
      if Base_Info.Type_Rti = O_Dnode_Null then
         Push_Identifier_Prefix (Mark, "BT");
         Base_Rti := Generate_Type_Definition (Base_Type);
         Pop_Identifier_Prefix (Mark);
      end if;

      Bounds := Info.T.Array_Bounds;
      Depth := Get_Depth_From_Var (Bounds);
      Info.T.Rti_Max_Depth :=
        Rti_Depth_Type'Max (Depth, Base_Info.T.Rti_Max_Depth);

      --  Generate node.
      Generate_Type_Rti (Info, Ghdl_Rtin_Subtype_Array);

      if Global_Storage = O_Storage_External then
         return;
      end if;

      Name := Generate_Type_Name (Atype);

      Start_Const_Value (Info.Type_Rti);
      Start_Record_Aggr (Aggr, Ghdl_Rtin_Subtype_Array);
      case Info.Type_Mode is
         when Type_Mode_Array =>
            Kind := Ghdl_Rtik_Subtype_Array;
         when Type_Mode_Fat_Array =>
            Kind := Ghdl_Rtik_Subtype_Unconstrained_Array;
         when others =>
            Error_Kind ("generate_array_subtype_definition", Atype);
      end case;
      New_Record_Aggr_El
        (Aggr,
         Generate_Common_Type
           (Kind, Depth, Info.T.Rti_Max_Depth, Type_To_Mode (Atype)));
      New_Record_Aggr_El (Aggr, New_Name_Address (Name));
      New_Record_Aggr_El (Aggr, New_Rti_Address (Base_Info.Type_Rti));
      if Bounds = Null_Var then
         Val := Get_Null_Loc;
      else
         Val := Var_Acc_To_Loc (Bounds);
      end if;
      New_Record_Aggr_El (Aggr, Val);
      for I in Mode_Value .. Mode_Signal loop
         case Info.Type_Mode is
            when Type_Mode_Array =>
               Val := Get_Null_Loc;
               if Info.Ortho_Type (I) /= O_Tnode_Null then
                  if Is_Complex_Type (Info) then
                     if Info.C (I).Size_Var /= Null_Var then
                        Val := Var_Acc_To_Loc (Info.C (I).Size_Var);
                     end if;
                  else
                     Val := New_Sizeof (Info.Ortho_Type (I),
                                        Ghdl_Ptr_Type);
                  end if;
               end if;
            when Type_Mode_Fat_Array =>
               Val := Get_Null_Loc;
            when others =>
               Error_Kind ("generate_array_subtype_definition", Atype);
         end case;
         New_Record_Aggr_El (Aggr, Val);
      end loop;

      Finish_Record_Aggr (Aggr, Val);
      Finish_Const_Value (Info.Type_Rti, Val);
   end Generate_Array_Subtype_Definition;

   procedure Generate_Record_Type_Definition (Atype : Iir)
   is
      El_List   : Iir_List;
      El        : Iir;
      Prev      : Rti_Block;
      El_Arr    : O_Dnode;
      Res       : O_Cnode;
      Info      : constant Type_Info_Acc := Get_Info (Atype);
      Max_Depth : Rti_Depth_Type;
   begin
      Generate_Type_Rti (Info, Ghdl_Rtin_Type_Record);
      if Global_Storage = O_Storage_External then
         return;
      end if;

      El_List := Get_Elements_Declaration_List (Atype);
      Max_Depth := 0;

      --  Generate elements.
      Push_Rti_Node (Prev, False);
      for I in Natural loop
         El := Get_Nth_Element (El_List, I);
         exit when El = Null_Iir;
         declare
            Type_Rti   : O_Dnode;
            El_Name    : O_Dnode;
            El_Type    : constant Iir := Get_Type (El);
            Aggr       : O_Record_Aggr_List;
            Field_Info : constant Field_Info_Acc := Get_Info (El);
            Val        : O_Cnode;
            El_Const   : O_Dnode;
            Mark       : Id_Mark_Type;
         begin
            Push_Identifier_Prefix (Mark, Get_Identifier (El));

            Type_Rti := Generate_Type_Definition (El_Type);
            Max_Depth :=
              Rti_Depth_Type'Max (Max_Depth,
                                  Get_Info (El_Type).T.Rti_Max_Depth);

            El_Name := Generate_Name (El);
            New_Const_Decl (El_Const, Create_Identifier ("RTIEL"),
                            Global_Storage, Ghdl_Rtin_Element);
            Start_Const_Value (El_Const);
            Start_Record_Aggr (Aggr, Ghdl_Rtin_Element);
            New_Record_Aggr_El (Aggr,
                                Generate_Common (Ghdl_Rtik_Element));
            New_Record_Aggr_El (Aggr, New_Name_Address (El_Name));
            New_Record_Aggr_El (Aggr, New_Rti_Address (Type_Rti));
            for I in Object_Kind_Type loop
               if Field_Info.Field_Node (I) /= O_Fnode_Null then
                  Val := New_Offsetof (Info.Ortho_Type (I),
                                       Field_Info.Field_Node (I),
                                       Ghdl_Index_Type);
               else
                  Val := Ghdl_Index_0;
               end if;
               New_Record_Aggr_El (Aggr, Val);
            end loop;
            Finish_Record_Aggr (Aggr, Val);
            Finish_Const_Value (El_Const, Val);
            Add_Rti_Node (El_Const);

            Pop_Identifier_Prefix (Mark);
         end;
      end loop;
      El_Arr := Generate_Rti_Array (Create_Identifier ("RTIARRAY"));
      Pop_Rti_Node (Prev);

      Info.T.Rti_Max_Depth := Max_Depth;
      --  Generate record.
      declare
         Aggr : O_Record_Aggr_List;
         Name : O_Dnode;
      begin
         Name := Generate_Type_Name (Atype);

         Start_Const_Value (Info.Type_Rti);
         Start_Record_Aggr (Aggr, Ghdl_Rtin_Type_Record);
         New_Record_Aggr_El
           (Aggr,
            Generate_Common_Type (Ghdl_Rtik_Type_Record, 0, Max_Depth,
              Type_To_Mode (Atype)));
         New_Record_Aggr_El (Aggr, New_Name_Address (Name));
         New_Record_Aggr_El
           (Aggr, New_Unsigned_Literal
              (Ghdl_Index_Type, Unsigned_64 (Get_Nbr_Elements (El_List))));
         New_Record_Aggr_El (Aggr,
                             New_Global_Address (El_Arr, Ghdl_Rti_Arr_Acc));
         Finish_Record_Aggr (Aggr, Res);
         Finish_Const_Value (Info.Type_Rti, Res);
      end;
   end Generate_Record_Type_Definition;

   procedure Generate_Protected_Type_Declaration (Atype : Iir)
   is
      Info : Type_Info_Acc;
      Name : O_Dnode;
      Val  : O_Cnode;
      List : O_Record_Aggr_List;
   begin
      Info := Get_Info (Atype);
      Generate_Type_Rti (Info, Ghdl_Rtin_Type_Scalar);
      if Global_Storage = O_Storage_External then
         return;
      end if;

      Name := Generate_Type_Name (Atype);
      Start_Const_Value (Info.Type_Rti);
      Start_Record_Aggr (List, Ghdl_Rtin_Type_Scalar);
      New_Record_Aggr_El
        (List,
         Generate_Common_Type (Ghdl_Rtik_Type_Protected, 0, 0,
           Type_To_Mode (Atype)));
      New_Record_Aggr_El (List, New_Name_Address (Name));
      Finish_Record_Aggr (List, Val);
      Finish_Const_Value (Info.Type_Rti, Val);
   end Generate_Protected_Type_Declaration;

   --  If FORCE is true, force the creation of the type RTI.
   --  Otherwise, only the declaration (and not the definition) may have
   --  been created.
   function Generate_Type_Definition (Atype : Iir; Force : Boolean := False)
                                         return O_Dnode
   is
      Info : constant Type_Info_Acc := Get_Info (Atype);
   begin
      if not Force and then Info.Type_Rti /= O_Dnode_Null then
         return Info.Type_Rti;
      end if;
      case Get_Kind (Atype) is
         when Iir_Kind_Integer_Type_Definition
            | Iir_Kind_Floating_Type_Definition
            | Iir_Kind_Physical_Type_Definition =>
            raise Internal_Error;
         when Iir_Kind_Enumeration_Type_Definition =>
            Generate_Enumeration_Type_Definition (Atype);
         when Iir_Kind_Integer_Subtype_Definition
            | Iir_Kind_Floating_Subtype_Definition
            | Iir_Kind_Enumeration_Subtype_Definition
            | Iir_Kind_Physical_Subtype_Definition =>
            Generate_Scalar_Subtype_Definition (Atype);
         when Iir_Kind_Array_Type_Definition =>
            Generate_Array_Type_Definition (Atype);
         when Iir_Kind_Array_Subtype_Definition =>
            Generate_Array_Subtype_Definition (Atype);
         when Iir_Kind_Access_Type_Definition
            | Iir_Kind_File_Type_Definition =>
            Generate_Fileacc_Type_Definition (Atype);
         when Iir_Kind_Record_Subtype_Definition
            | Iir_Kind_Access_Subtype_Definition =>
            --  FIXME: No separate infos (yet).
            null;
         when Iir_Kind_Record_Type_Definition =>
            Generate_Record_Type_Definition (Atype);
         when Iir_Kind_Protected_Type_Declaration =>
            Generate_Protected_Type_Declaration (Atype);
         when others =>
            Error_Kind ("rti.generate_type_definition", Atype);
            return O_Dnode_Null;
      end case;
      return Info.Type_Rti;
   end Generate_Type_Definition;

   function Generate_Incomplete_Type_Definition (Def : Iir)
                                                    return O_Dnode
   is
      Ndef     : constant Iir := Get_Type (Get_Type_Declarator (Def));
      Info     : constant Type_Info_Acc := Get_Info (Ndef);
      Rti_Type : O_Tnode;
   begin
      case Get_Kind (Ndef) is
         when Iir_Kind_Integer_Type_Definition
            | Iir_Kind_Floating_Type_Definition =>
            Rti_Type := Ghdl_Rtin_Type_Scalar;
         when Iir_Kind_Physical_Type_Definition =>
            Rti_Type := Ghdl_Rtin_Type_Physical;
         when Iir_Kind_Enumeration_Type_Definition =>
            Rti_Type := Ghdl_Rtin_Type_Enum;
         when Iir_Kind_Integer_Subtype_Definition
            | Iir_Kind_Floating_Subtype_Definition
            | Iir_Kind_Enumeration_Subtype_Definition
            | Iir_Kind_Physical_Subtype_Definition =>
            Rti_Type := Ghdl_Rtin_Subtype_Scalar;
         when Iir_Kind_Array_Type_Definition =>
            Rti_Type := Ghdl_Rtin_Type_Array;
         when Iir_Kind_Array_Subtype_Definition =>
            Rti_Type := Ghdl_Rtin_Subtype_Array;
         when Iir_Kind_Access_Type_Definition
            | Iir_Kind_File_Type_Definition =>
            Rti_Type := Ghdl_Rtin_Type_Fileacc;
         when Iir_Kind_Record_Type_Definition =>
            Rti_Type := Ghdl_Rtin_Type_Record;
         when others =>
            Error_Kind ("rti.generate_incomplete_type_definition", Ndef);
      end case;
      New_Const_Decl (Info.Type_Rti, Create_Identifier ("RTI"),
                      Global_Storage, Rti_Type);
      return Info.Type_Rti;
   end Generate_Incomplete_Type_Definition;

   function Generate_Type_Decl (Decl : Iir) return O_Dnode
   is
      Id   : constant Name_Id := Get_Identifier (Decl);
      Def  : constant Iir := Get_Type (Decl);
      Rti  : O_Dnode;
      Mark : Id_Mark_Type;
   begin
      Push_Identifier_Prefix (Mark, Id);
      if Get_Kind (Def) = Iir_Kind_Incomplete_Type_Definition then
         Rti := Generate_Incomplete_Type_Definition (Def);
      else
         Rti := Generate_Type_Definition (Def, True);
      end if;
      Pop_Identifier_Prefix (Mark);
      return Rti;
   end Generate_Type_Decl;

   procedure Generate_Signal_Rti (Sig : Iir)
   is
      Info : Object_Info_Acc;
   begin
      Info := Get_Info (Sig);
      New_Const_Decl (Info.Object_Rti, Create_Identifier (Sig, "__RTI"),
                      Global_Storage, Ghdl_Rtin_Object);
   end Generate_Signal_Rti;

   function Generate_Linecol (Decl : Iir) return O_Cnode
   is
      Line : Natural;
      Col : Natural;
      Name : Name_Id;
   begin
      Files_Map.Location_To_Position (Get_Location (Decl), Name, Line, Col);

      --  Saturate col and line.
      Col := Natural'Min (Col, 255);
      Line := Natural'Min (Line, 2**24 - 1);
      return Helpers.New_Index_Lit
        (Unsigned_64 (Line) * 256 + Unsigned_64 (Col));
   end Generate_Linecol;

   procedure Generate_Object (Decl : Iir; Rti : in out O_Dnode)
   is
      Decl_Type : Iir;
      Type_Info : Type_Info_Acc;
      Name      : O_Dnode;
      Comm      : O_Cnode;
      Val       : O_Cnode;
      List      : O_Record_Aggr_List;
      Info      : Ortho_Info_Acc;
      Mark      : Id_Mark_Type;
      Var       : Var_Type;
      Mode      : Natural;
      Has_Id    : Boolean;
   begin
      case Get_Kind (Decl) is
         when Iir_Kind_Transaction_Attribute
            | Iir_Kind_Stable_Attribute
            | Iir_Kind_Quiet_Attribute
            | Iir_Kind_Delayed_Attribute =>
            Has_Id := False;
            Push_Identifier_Prefix_Uniq (Mark);
         when others =>
            Has_Id := True;
            Push_Identifier_Prefix (Mark, Get_Identifier (Decl));
      end case;

      if Rti = O_Dnode_Null then
         New_Const_Decl (Rti, Create_Identifier ("RTI"),
                         Global_Storage, Ghdl_Rtin_Object);
      end if;

      if Global_Storage /= O_Storage_External then
         Decl_Type := Get_Type (Decl);
         Type_Info := Get_Info (Decl_Type);
         if Type_Info.Type_Rti = O_Dnode_Null then
            declare
               Mark : Id_Mark_Type;
               Tmp  : O_Dnode;
               pragma Unreferenced (Tmp);
            begin
               Push_Identifier_Prefix (Mark, "OT");
               Tmp := Generate_Type_Definition (Decl_Type);
               Pop_Identifier_Prefix (Mark);
            end;
         end if;

         if Has_Id then
            Name := Generate_Name (Decl);
         else
            Name := O_Dnode_Null;
         end if;

         Info := Get_Info (Decl);

         Start_Const_Value (Rti);
         Start_Record_Aggr (List, Ghdl_Rtin_Object);
         Mode := 0;
         case Get_Kind (Decl) is
            when Iir_Kind_Signal_Declaration =>
               Comm := Ghdl_Rtik_Signal;
               Var := Info.Object_Var;
            when Iir_Kind_Interface_Signal_Declaration =>
               Comm := Ghdl_Rtik_Port;
               Var := Info.Object_Var;
               Mode := Iir_Mode'Pos (Get_Mode (Decl));
            when Iir_Kind_Constant_Declaration =>
               Comm := Ghdl_Rtik_Constant;
               Var := Info.Object_Var;
            when Iir_Kind_Interface_Constant_Declaration =>
               Comm := Ghdl_Rtik_Generic;
               Var := Info.Object_Var;
            when Iir_Kind_Variable_Declaration =>
               Comm := Ghdl_Rtik_Variable;
               Var := Info.Object_Var;
            when Iir_Kind_Guard_Signal_Declaration =>
               Comm := Ghdl_Rtik_Guard;
               Var := Info.Object_Var;
            when Iir_Kind_Iterator_Declaration =>
               Comm := Ghdl_Rtik_Iterator;
               Var := Info.Iterator_Var;
            when Iir_Kind_File_Declaration =>
               Comm := Ghdl_Rtik_File;
               Var := Info.Object_Var;
            when Iir_Kind_Attribute_Declaration =>
               Comm := Ghdl_Rtik_Attribute;
               Var := Null_Var;
            when Iir_Kind_Transaction_Attribute =>
               Comm := Ghdl_Rtik_Attribute_Transaction;
               Var := Info.Object_Var;
            when Iir_Kind_Quiet_Attribute =>
               Comm := Ghdl_Rtik_Attribute_Quiet;
               Var := Info.Object_Var;
            when Iir_Kind_Stable_Attribute =>
               Comm := Ghdl_Rtik_Attribute_Stable;
               Var := Info.Object_Var;
            when Iir_Kind_Object_Alias_Declaration =>
               Comm := Ghdl_Rtik_Alias;
               Var := Info.Alias_Var;
               Mode := Object_Kind_Type'Pos (Info.Alias_Kind);
            when others =>
               Error_Kind ("rti.generate_object", Decl);
         end case;
         case Get_Kind (Decl) is
            when Iir_Kind_Signal_Declaration
               | Iir_Kind_Interface_Signal_Declaration =>
               Mode := Mode
                 + 16 * Iir_Signal_Kind'Pos (Get_Signal_Kind (Decl));
            when others =>
               null;
         end case;
         case Get_Kind (Decl) is
            when Iir_Kind_Signal_Declaration
               | Iir_Kind_Interface_Signal_Declaration
               | Iir_Kind_Guard_Signal_Declaration
               | Iir_Kind_Transaction_Attribute
               | Iir_Kind_Stable_Attribute
               | Iir_Kind_Quiet_Attribute
               | Iir_Kind_Delayed_Attribute =>
               if Get_Has_Active_Flag (Decl) then
                  Mode := Mode + 64;
               end if;
            when others =>
               null;
         end case;
         New_Record_Aggr_El (List, Generate_Common (Comm, Var, Mode));
         New_Record_Aggr_El (List, New_Name_Address (Name));
         if Var = Null_Var then
            Val := Get_Null_Loc;
         else
            Val := Var_Acc_To_Loc (Var);
         end if;
         New_Record_Aggr_El (List, Val);
         New_Record_Aggr_El (List, New_Rti_Address (Type_Info.Type_Rti));
         New_Record_Aggr_El (List, Generate_Linecol (Decl));
         Finish_Record_Aggr (List, Val);
         Finish_Const_Value (Rti, Val);
      end if;
      Pop_Identifier_Prefix (Mark);
   end Generate_Object;

   procedure Generate_Block (Blk : Iir; Parent_Rti : O_Dnode);
   procedure Generate_Declaration_Chain (Chain : Iir);

   procedure Generate_Component_Declaration (Comp : Iir)
   is
      Prev : Rti_Block;
      Name : O_Dnode;
      Arr  : O_Dnode;
      List : O_Record_Aggr_List;
      Res  : O_Cnode;
      Mark : Id_Mark_Type;
      Info : Comp_Info_Acc;
   begin
      Push_Identifier_Prefix (Mark, Get_Identifier (Comp));
      Info := Get_Info (Comp);

      New_Const_Decl (Info.Comp_Rti_Const, Create_Identifier ("RTI"),
                      Global_Storage, Ghdl_Rtin_Component);

      if Global_Storage /= O_Storage_External then
         Push_Rti_Node (Prev);

         Generate_Declaration_Chain (Get_Generic_Chain (Comp));
         Generate_Declaration_Chain (Get_Port_Chain (Comp));

         Name := Generate_Name (Comp);

         Arr := Generate_Rti_Array (Create_Identifier ("RTIARRAY"));

         Start_Const_Value (Info.Comp_Rti_Const);
         Start_Record_Aggr (List, Ghdl_Rtin_Component);
         New_Record_Aggr_El (List, Generate_Common (Ghdl_Rtik_Component));
         New_Record_Aggr_El (List,
                             New_Global_Address (Name, Char_Ptr_Type));
         New_Record_Aggr_El
           (List, New_Unsigned_Literal (Ghdl_Index_Type,
            Unsigned_64 (Cur_Block.Nbr)));
         New_Record_Aggr_El (List,
                             New_Global_Address (Arr, Ghdl_Rti_Arr_Acc));
         Finish_Record_Aggr (List, Res);
         Finish_Const_Value (Info.Comp_Rti_Const, Res);
         Pop_Rti_Node (Prev);
      end if;

      Pop_Identifier_Prefix (Mark);
      Add_Rti_Node (Info.Comp_Rti_Const);
   end Generate_Component_Declaration;

   --  Generate RTIs only for types.
   procedure Generate_Declaration_Chain_Depleted (Chain : Iir)
   is
      Decl : Iir;
   begin
      Decl := Chain;
      while Decl /= Null_Iir loop
         case Get_Kind (Decl) is
            when Iir_Kind_Use_Clause =>
               null;
            when Iir_Kind_Type_Declaration =>
               --  FIXME: physicals ?
               if Get_Kind (Get_Type_Definition (Decl))
                 = Iir_Kind_Enumeration_Type_Definition
               then
                  Add_Rti_Node (Generate_Type_Decl (Decl));
               end if;
            when Iir_Kind_Subtype_Declaration =>
               --  In a subprogram, a subtype may depends on parameters.
               --  Eg: array subtypes.
               null;
            when Iir_Kind_Signal_Declaration
               | Iir_Kind_Interface_Signal_Declaration
               | Iir_Kind_Constant_Declaration
               | Iir_Kind_Interface_Constant_Declaration
               | Iir_Kind_Variable_Declaration
               | Iir_Kind_File_Declaration
               | Iir_Kind_Transaction_Attribute
               | Iir_Kind_Quiet_Attribute
               | Iir_Kind_Stable_Attribute =>
               null;
            when Iir_Kind_Delayed_Attribute =>
               --  FIXME: to be added.
               null;
            when Iir_Kind_Object_Alias_Declaration
               | Iir_Kind_Attribute_Declaration =>
               null;
            when Iir_Kind_Component_Declaration =>
               null;
            when Iir_Kind_Implicit_Function_Declaration
               | Iir_Kind_Implicit_Procedure_Declaration
               | Iir_Kind_Function_Declaration
               | Iir_Kind_Procedure_Declaration =>
               --  FIXME: to be added (for foreign).
               null;
            when Iir_Kind_Function_Body
               | Iir_Kind_Procedure_Body =>
               null;
            when Iir_Kind_Anonymous_Type_Declaration =>
               --  Handled in subtype declaration.
               null;
            when Iir_Kind_Configuration_Specification
               | Iir_Kind_Attribute_Specification
               | Iir_Kind_Disconnection_Specification =>
               null;
            when Iir_Kind_Protected_Type_Body =>
               null;
            when Iir_Kind_Non_Object_Alias_Declaration =>
               null;
            when Iir_Kind_Group_Template_Declaration
               | Iir_Kind_Group_Declaration =>
               null;
            when others =>
               Error_Kind ("rti.generate_declaration_chain_depleted", Decl);
         end case;
         Decl := Get_Chain (Decl);
      end loop;
   end Generate_Declaration_Chain_Depleted;

   procedure Generate_Subprogram_Body (Bod : Iir)
   is
      --Decl : Iir;
      --Mark : Id_Mark_Type;
   begin
      --Decl := Get_Subprogram_Specification (Bod);

      --Push_Identifier_Prefix (Mark, Get_Identifier (Decl));
      --  Generate RTI only for types.
      Generate_Declaration_Chain_Depleted (Get_Declaration_Chain (Bod));
      --Pop_Identifier_Prefix (Mark);
   end Generate_Subprogram_Body;

   procedure Generate_Instance (Stmt : Iir; Parent : O_Dnode)
   is
      Name : O_Dnode;
      List : O_Record_Aggr_List;
      Val  : O_Cnode;
      Inst : constant Iir := Get_Instantiated_Unit (Stmt);
      Info : constant Block_Info_Acc := Get_Info (Stmt);
   begin
      Name := Generate_Name (Stmt);

      New_Const_Decl (Info.Block_Rti_Const, Create_Identifier ("RTI"),
                      Global_Storage, Ghdl_Rtin_Instance);

      Start_Const_Value (Info.Block_Rti_Const);
      Start_Record_Aggr (List, Ghdl_Rtin_Instance);
      New_Record_Aggr_El (List, Generate_Common (Ghdl_Rtik_Instance));
      New_Record_Aggr_El (List, New_Global_Address (Name, Char_Ptr_Type));
      New_Record_Aggr_El (List, Generate_Linecol (Stmt));
      New_Record_Aggr_El
        (List, New_Offsetof (Get_Scope_Type
                               (Get_Info (Get_Parent (Stmt)).Block_Scope),
                             Info.Block_Link_Field,
                             Ghdl_Ptr_Type));
      New_Record_Aggr_El (List, New_Rti_Address (Parent));
      if Is_Component_Instantiation (Stmt) then
         Val := New_Rti_Address
           (Get_Info (Get_Named_Entity (Inst)).Comp_Rti_Const);
      else
         declare
            Ent : constant Iir := Get_Entity_From_Entity_Aspect (Inst);
         begin
            Val := New_Rti_Address (Get_Info (Ent).Block_Rti_Const);
         end;
      end if;

      New_Record_Aggr_El (List, Val);
      Finish_Record_Aggr (List, Val);
      Finish_Const_Value (Info.Block_Rti_Const, Val);
      Add_Rti_Node (Info.Block_Rti_Const);
   end Generate_Instance;

   procedure Generate_Psl_Directive (Stmt : Iir)
   is
      Name : O_Dnode;
      List : O_Record_Aggr_List;

      Rti  : O_Dnode;
      Res  : O_Cnode;
      Info : constant Psl_Info_Acc := Get_Info (Stmt);
      Mark : Id_Mark_Type;
   begin
      Push_Identifier_Prefix (Mark, Get_Identifier (Stmt));
      Name := Generate_Name (Stmt);

      New_Const_Decl (Rti, Create_Identifier ("RTI"),
                      O_Storage_Public, Ghdl_Rtin_Type_Scalar);

      Start_Const_Value (Rti);
      Start_Record_Aggr (List, Ghdl_Rtin_Type_Scalar);
      New_Record_Aggr_El (List, Generate_Common (Ghdl_Rtik_Psl_Assert));
      New_Record_Aggr_El (List, New_Global_Address (Name, Char_Ptr_Type));
      Finish_Record_Aggr (List, Res);
      Finish_Const_Value (Rti, Res);
      Info.Psl_Rti_Const := Rti;
      Pop_Identifier_Prefix (Mark);
   end Generate_Psl_Directive;

   procedure Generate_Declaration_Chain (Chain : Iir)
   is
      Decl : Iir;
   begin
      Decl := Chain;
      while Decl /= Null_Iir loop
         case Get_Kind (Decl) is
            when Iir_Kind_Use_Clause =>
               null;
            when Iir_Kind_Anonymous_Type_Declaration =>
               --  Handled in subtype declaration.
               null;
            when Iir_Kind_Type_Declaration
               | Iir_Kind_Subtype_Declaration =>
               Add_Rti_Node (Generate_Type_Decl (Decl));
            when Iir_Kind_Constant_Declaration =>
               --  Do not generate RTIs for full declarations.
               --  (RTI will be generated for the deferred declaration).
               if Get_Deferred_Declaration (Decl) = Null_Iir
                 or else Get_Deferred_Declaration_Flag (Decl)
               then
                  declare
                     Info : Object_Info_Acc;
                  begin
                     Info := Get_Info (Decl);
                     Generate_Object (Decl, Info.Object_Rti);
                     Add_Rti_Node (Info.Object_Rti);
                  end;
               end if;
            when Iir_Kind_Signal_Declaration
               | Iir_Kind_Interface_Signal_Declaration
               | Iir_Kind_Interface_Constant_Declaration
               | Iir_Kind_Variable_Declaration
               | Iir_Kind_File_Declaration
               | Iir_Kind_Transaction_Attribute
               | Iir_Kind_Quiet_Attribute
               | Iir_Kind_Stable_Attribute =>
               declare
                  Info : Object_Info_Acc;
               begin
                  Info := Get_Info (Decl);
                  Generate_Object (Decl, Info.Object_Rti);
                  Add_Rti_Node (Info.Object_Rti);
               end;
            when Iir_Kind_Delayed_Attribute =>
               --  FIXME: to be added.
               null;
            when Iir_Kind_Object_Alias_Declaration
               | Iir_Kind_Attribute_Declaration =>
               declare
                  Rti : O_Dnode := O_Dnode_Null;
               begin
                  Generate_Object (Decl, Rti);
                  Add_Rti_Node (Rti);
               end;
            when Iir_Kind_Component_Declaration =>
               Generate_Component_Declaration (Decl);
            when Iir_Kind_Implicit_Function_Declaration
               | Iir_Kind_Implicit_Procedure_Declaration
               | Iir_Kind_Function_Declaration
               | Iir_Kind_Procedure_Declaration =>
               --  FIXME: to be added (for foreign).
               null;
            when Iir_Kind_Function_Body
               | Iir_Kind_Procedure_Body =>
               --  Already handled by Translate_Subprogram_Body.
               null;
            when Iir_Kind_Configuration_Specification
               | Iir_Kind_Attribute_Specification
               | Iir_Kind_Disconnection_Specification =>
               null;
            when Iir_Kind_Protected_Type_Body =>
               null;
            when Iir_Kind_Non_Object_Alias_Declaration =>
               null;
            when Iir_Kind_Group_Template_Declaration
               | Iir_Kind_Group_Declaration =>
               null;
            when others =>
               Error_Kind ("rti.generate_declaration_chain", Decl);
         end case;
         Decl := Get_Chain (Decl);
      end loop;
   end Generate_Declaration_Chain;

   procedure Generate_Concurrent_Statement_Chain
     (Chain : Iir; Parent_Rti : O_Dnode)
   is
      Stmt : Iir;
      Mark : Id_Mark_Type;
   begin
      Stmt := Chain;
      while Stmt /= Null_Iir loop
         case Get_Kind (Stmt) is
            when Iir_Kind_Process_Statement
               | Iir_Kind_Sensitized_Process_Statement
               | Iir_Kind_Block_Statement
               | Iir_Kind_Generate_Statement =>
               Push_Identifier_Prefix (Mark, Get_Identifier (Stmt));
               Generate_Block (Stmt, Parent_Rti);
               Pop_Identifier_Prefix (Mark);
            when Iir_Kind_Component_Instantiation_Statement =>
               Push_Identifier_Prefix (Mark, Get_Identifier (Stmt));
               Generate_Instance (Stmt, Parent_Rti);
               Pop_Identifier_Prefix (Mark);
            when Iir_Kind_Psl_Default_Clock =>
               null;
            when Iir_Kind_Psl_Declaration =>
               null;
            when Iir_Kind_Psl_Assert_Statement =>
               Generate_Psl_Directive (Stmt);
            when Iir_Kind_Psl_Cover_Statement =>
               Generate_Psl_Directive (Stmt);
            when others =>
               Error_Kind ("rti.generate_concurrent_statement_chain", Stmt);
         end case;
         Stmt := Get_Chain (Stmt);
      end loop;
   end Generate_Concurrent_Statement_Chain;

   procedure Generate_Block (Blk : Iir; Parent_Rti : O_Dnode)
   is
      Name : O_Dnode;
      Arr  : O_Dnode;
      List : O_Record_Aggr_List;
      List_File : O_Record_Aggr_List;

      Rti_Type : O_Tnode;
      Rti : O_Dnode;

      Kind : O_Cnode;
      Res  : O_Cnode;

      Prev : Rti_Block;
      Info : Ortho_Info_Acc;

      Field_Off : O_Cnode;
      Inst      : O_Tnode;
   begin
      --  The type of a generator iterator is elaborated in the parent.
      if Get_Kind (Blk) = Iir_Kind_Generate_Statement then
         declare
            Scheme    : constant Iir := Get_Generation_Scheme (Blk);
            Iter_Type : Iir;
            Type_Info : Type_Info_Acc;
            Mark      : Id_Mark_Type;
            Tmp       : O_Dnode;
         begin
            if Get_Kind (Scheme) = Iir_Kind_Iterator_Declaration then
               Iter_Type := Get_Type (Scheme);
               Type_Info := Get_Info (Iter_Type);
               if Type_Info.Type_Rti = O_Dnode_Null then
                  Push_Identifier_Prefix (Mark, "ITERATOR");
                  Tmp := Generate_Type_Definition (Iter_Type);
                  Add_Rti_Node (Tmp);
                  Pop_Identifier_Prefix (Mark);
               end if;
            end if;
         end;
      end if;

      if Get_Kind (Get_Parent (Blk)) = Iir_Kind_Design_Unit then
         Rti_Type := Ghdl_Rtin_Block_File;
      else
         Rti_Type := Ghdl_Rtin_Block;
      end if;

      New_Const_Decl (Rti, Create_Identifier ("RTI"),
                      O_Storage_Public, Rti_Type);
      Push_Rti_Node (Prev);

      Field_Off := O_Cnode_Null;
      Inst := O_Tnode_Null;
      Info := Get_Info (Blk);
      case Get_Kind (Blk) is
         when Iir_Kind_Package_Declaration =>
            Kind := Ghdl_Rtik_Package;
            Generate_Declaration_Chain (Get_Declaration_Chain (Blk));
         when Iir_Kind_Package_Body =>
            Kind := Ghdl_Rtik_Package_Body;
            --  Required at least for 'image
            Generate_Declaration_Chain (Get_Declaration_Chain (Blk));
         when Iir_Kind_Architecture_Body =>
            Kind := Ghdl_Rtik_Architecture;
            Generate_Declaration_Chain (Get_Declaration_Chain (Blk));
            Generate_Concurrent_Statement_Chain
              (Get_Concurrent_Statement_Chain (Blk), Rti);
            Inst := Get_Scope_Type (Info.Block_Scope);
            Field_Off := New_Offsetof
              (Get_Scope_Type (Info.Block_Scope),
               Info.Block_Parent_Field, Ghdl_Ptr_Type);
         when Iir_Kind_Entity_Declaration =>
            Kind := Ghdl_Rtik_Entity;
            Generate_Declaration_Chain (Get_Generic_Chain (Blk));
            Generate_Declaration_Chain (Get_Port_Chain (Blk));
            Generate_Declaration_Chain (Get_Declaration_Chain (Blk));
            Generate_Concurrent_Statement_Chain
              (Get_Concurrent_Statement_Chain (Blk), Rti);
            Inst := Get_Scope_Type (Info.Block_Scope);
         when Iir_Kind_Process_Statement
            | Iir_Kind_Sensitized_Process_Statement =>
            Kind := Ghdl_Rtik_Process;
            Generate_Declaration_Chain (Get_Declaration_Chain (Blk));
            Field_Off :=
              Get_Scope_Offset (Info.Process_Scope, Ghdl_Ptr_Type);
            Inst := Get_Scope_Type (Info.Process_Scope);
         when Iir_Kind_Block_Statement =>
            Kind := Ghdl_Rtik_Block;
            declare
               Guard      : constant Iir := Get_Guard_Decl (Blk);
               Header     : constant Iir := Get_Block_Header (Blk);
               Guard_Info : Object_Info_Acc;
            begin
               if Guard /= Null_Iir then
                  Guard_Info := Get_Info (Guard);
                  Generate_Object (Guard, Guard_Info.Object_Rti);
                  Add_Rti_Node (Guard_Info.Object_Rti);
               end if;
               if Header /= Null_Iir then
                  Generate_Declaration_Chain (Get_Generic_Chain (Header));
                  Generate_Declaration_Chain (Get_Port_Chain (Header));
               end if;
            end;
            Generate_Declaration_Chain (Get_Declaration_Chain (Blk));
            Generate_Concurrent_Statement_Chain
              (Get_Concurrent_Statement_Chain (Blk), Rti);
            Field_Off := Get_Scope_Offset (Info.Block_Scope, Ghdl_Ptr_Type);
            Inst := Get_Scope_Type (Info.Block_Scope);
         when Iir_Kind_Generate_Statement =>
            declare
               Scheme     : constant Iir := Get_Generation_Scheme (Blk);
               Scheme_Rti : O_Dnode := O_Dnode_Null;
            begin
               if Get_Kind (Scheme) = Iir_Kind_Iterator_Declaration then
                  Generate_Object (Scheme, Scheme_Rti);
                  Add_Rti_Node (Scheme_Rti);
                  Kind := Ghdl_Rtik_For_Generate;
               else
                  Kind := Ghdl_Rtik_If_Generate;
               end if;
            end;
            Generate_Declaration_Chain (Get_Declaration_Chain (Blk));
            Generate_Concurrent_Statement_Chain
              (Get_Concurrent_Statement_Chain (Blk), Rti);
            Inst := Get_Scope_Type (Info.Block_Scope);
            Field_Off := New_Offsetof
              (Get_Scope_Type (Get_Info (Get_Parent (Blk)).Block_Scope),
               Info.Block_Parent_Field, Ghdl_Ptr_Type);
         when others =>
            Error_Kind ("rti.generate_block", Blk);
      end case;

      Name := Generate_Name (Blk);

      Arr := Generate_Rti_Array (Create_Identifier ("RTIARRAY"));

      Start_Const_Value (Rti);

      if Rti_Type = Ghdl_Rtin_Block_File then
         Start_Record_Aggr (List_File, Rti_Type);
      end if;

      Start_Record_Aggr (List, Ghdl_Rtin_Block);
      New_Record_Aggr_El (List, Generate_Common (Kind));
      New_Record_Aggr_El (List, New_Global_Address (Name, Char_Ptr_Type));
      if Field_Off = O_Cnode_Null then
         Field_Off := Get_Null_Loc;
      end if;
      New_Record_Aggr_El (List, Field_Off);
      New_Record_Aggr_El (List, Generate_Linecol (Blk));
      if Parent_Rti = O_Dnode_Null then
         Res := New_Null_Access (Ghdl_Rti_Access);
      else
         Res := New_Rti_Address (Parent_Rti);
      end if;
      New_Record_Aggr_El (List, Res);
      if Inst = O_Tnode_Null then
         Res := Ghdl_Index_0;
      else
         Res := New_Sizeof (Inst, Ghdl_Index_Type);
      end if;
      New_Record_Aggr_El (List, Res);
      New_Record_Aggr_El
        (List, New_Unsigned_Literal (Ghdl_Index_Type,
         Unsigned_64 (Cur_Block.Nbr)));
      New_Record_Aggr_El (List, New_Global_Address (Arr, Ghdl_Rti_Arr_Acc));
      Finish_Record_Aggr (List, Res);

      if Rti_Type = Ghdl_Rtin_Block_File then
         New_Record_Aggr_El (List_File, Res);
         New_Record_Aggr_El (List_File,
                             New_Global_Address (Current_Filename_Node,
                                                 Char_Ptr_Type));
         Finish_Record_Aggr (List_File, Res);
      end if;

      Finish_Const_Value (Rti, Res);

      Pop_Rti_Node (Prev);

      --  Put children in the parent list.
      case Get_Kind (Blk) is
         when Iir_Kind_Block_Statement
            | Iir_Kind_Generate_Statement
            | Iir_Kind_Process_Statement
            | Iir_Kind_Sensitized_Process_Statement =>
            Add_Rti_Node (Rti);
         when others =>
            null;
      end case;

      --  Store the RTI.
      case Get_Kind (Blk) is
         when Iir_Kind_Entity_Declaration
            | Iir_Kind_Architecture_Body
            | Iir_Kind_Block_Statement
            | Iir_Kind_Generate_Statement =>
            Info.Block_Rti_Const := Rti;
         when Iir_Kind_Process_Statement
            | Iir_Kind_Sensitized_Process_Statement =>
            Info.Process_Rti_Const := Rti;
         when Iir_Kind_Package_Declaration =>
            Info.Package_Rti_Const := Rti;
         when Iir_Kind_Package_Body =>
            --  Replace package declaration RTI with the body one.
            Get_Info (Get_Package (Blk)).Package_Rti_Const := Rti;
         when others =>
            Error_Kind ("rti.generate_block", Blk);
      end case;
   end Generate_Block;

   procedure Generate_Library (Lib    : Iir_Library_Declaration;
                               Public : Boolean)
   is
      use Name_Table;
      Info    : Library_Info_Acc;
      Id      : Name_Id;
      Val     : O_Cnode;
      Aggr    : O_Record_Aggr_List;
      Name    : O_Dnode;
      Storage : O_Storage;
   begin
      Info := Get_Info (Lib);
      if Info /= null then
         --  Already generated.
         return;
      end if;
      Info := Add_Info (Lib, Kind_Library);

      if Lib = Libraries.Work_Library then
         Id := Libraries.Work_Library_Name;
      else
         Id := Get_Identifier (Lib);
      end if;

      if Public then
         Storage := O_Storage_Public;
      else
         Storage := O_Storage_External;
      end if;

      New_Const_Decl (Info.Library_Rti_Const,
                      Create_Identifier_Without_Prefix (Id, "__RTI"),
                      Storage, Ghdl_Rtin_Type_Scalar);

      if Public then
         Image (Id);
         Name := Create_String
           (Name_Buffer (1 .. Name_Length),
            Create_Identifier_Without_Prefix (Id, "__RTISTR"));
         Start_Const_Value (Info.Library_Rti_Const);
         Start_Record_Aggr (Aggr, Ghdl_Rtin_Type_Scalar);
         New_Record_Aggr_El (Aggr, Generate_Common (Ghdl_Rtik_Library));
         New_Record_Aggr_El (Aggr, New_Name_Address (Name));
         Finish_Record_Aggr (Aggr, Val);
         Finish_Const_Value (Info.Library_Rti_Const, Val);
      end if;
   end Generate_Library;

   procedure Generate_Unit (Lib_Unit : Iir)
   is
      Info : constant Ortho_Info_Acc := Get_Info (Lib_Unit);
      Rti  : O_Dnode;
      Mark : Id_Mark_Type;
   begin
      case Get_Kind (Lib_Unit) is
         when Iir_Kind_Configuration_Declaration =>
            --  No RTI for configurations.
            return;
         when Iir_Kind_Architecture_Body =>
            if Info.Block_Rti_Const /= O_Dnode_Null then
               return;
            end if;
         when Iir_Kind_Package_Body =>
            Push_Identifier_Prefix (Mark, "BODY");
         when others =>
            null;
      end case;

      --  Declare node.
      if Global_Storage = O_Storage_External then
         New_Const_Decl (Rti, Create_Identifier ("RTI"),
                         O_Storage_External, Ghdl_Rtin_Block);
         case Get_Kind (Lib_Unit) is
            when Iir_Kind_Entity_Declaration
               | Iir_Kind_Package_Declaration =>
               declare
                  Prev : Rti_Block;
               begin
                  Push_Rti_Node (Prev);
                  Generate_Declaration_Chain
                    (Get_Declaration_Chain (Lib_Unit));
                  Pop_Rti_Node (Prev);
               end;
            when others =>
               null;
         end case;
         case Get_Kind (Lib_Unit) is
            when Iir_Kind_Entity_Declaration
               | Iir_Kind_Architecture_Body =>
               Info.Block_Rti_Const := Rti;
            when Iir_Kind_Package_Declaration =>
               Info.Package_Rti_Const := Rti;
            when Iir_Kind_Package_Body =>
               --  Replace package declaration RTI with the body one.
               Get_Info (Get_Package (Lib_Unit)).Package_Rti_Const := Rti;
            when others =>
               null;
         end case;
      else
         --  Compute parent RTI.
         case Get_Kind (Lib_Unit) is
            when Iir_Kind_Package_Declaration
               | Iir_Kind_Entity_Declaration
               | Iir_Kind_Configuration_Declaration =>
               --  The library.
               declare
                  Lib : Iir_Library_Declaration;
               begin
                  Lib := Get_Library (Get_Design_File
                                      (Get_Design_Unit (Lib_Unit)));
                  Generate_Library (Lib, False);
                  Rti := Get_Info (Lib).Library_Rti_Const;
               end;
            when Iir_Kind_Package_Body =>
               --  The package spec.
               Rti := Get_Info (Get_Package (Lib_Unit)).Package_Rti_Const;
            when Iir_Kind_Architecture_Body =>
               --  The entity.
               Rti := Get_Info (Get_Entity (Lib_Unit)).Block_Rti_Const;
            when others =>
               raise Internal_Error;
         end case;

         --  Generate RTI for Lib_Unit, using parent RTI.
         Generate_Block (Lib_Unit, Rti);
      end if;

      if Get_Kind (Lib_Unit) = Iir_Kind_Package_Body then
         Pop_Identifier_Prefix (Mark);
      end if;
   end Generate_Unit;

   procedure Generate_Top (Nbr_Pkgs : out Natural)
   is
      use Configuration;

      Unit : Iir_Design_Unit;
      Lib  : Iir_Library_Declaration;
      Prev : Rti_Block;
   begin
      Push_Rti_Node (Prev);

      --  Generate RTI for libraries, count number of packages.
      Nbr_Pkgs := 1; --  At least std.standard.
      for I in Design_Units.First .. Design_Units.Last loop
         Unit := Design_Units.Table (I);

         --  Generate RTI for the library.
         Lib := Get_Library (Get_Design_File (Unit));
         Generate_Library (Lib, True);

         if Get_Kind (Get_Library_Unit (Unit)) = Iir_Kind_Package_Declaration
         then
            Nbr_Pkgs := Nbr_Pkgs + 1;
         end if;
      end loop;

      Pop_Rti_Node (Prev);
   end Generate_Top;

   function Get_Context_Rti (Node : Iir) return O_Cnode
   is
      Node_Info : constant Ortho_Info_Acc := Get_Info (Node);
      Rti_Const : O_Dnode;
   begin
      case Get_Kind (Node) is
         when Iir_Kind_Component_Declaration =>
            Rti_Const := Node_Info.Comp_Rti_Const;
         when Iir_Kind_Component_Instantiation_Statement =>
            Rti_Const := Node_Info.Block_Rti_Const;
         when Iir_Kind_Entity_Declaration
            | Iir_Kind_Architecture_Body
            | Iir_Kind_Block_Statement
            | Iir_Kind_Generate_Statement =>
            Rti_Const := Node_Info.Block_Rti_Const;
         when Iir_Kind_Package_Declaration
            | Iir_Kind_Package_Body =>
            Rti_Const := Node_Info.Package_Rti_Const;
         when Iir_Kind_Process_Statement
            | Iir_Kind_Sensitized_Process_Statement =>
            Rti_Const := Node_Info.Process_Rti_Const;
         when Iir_Kind_Psl_Assert_Statement
            | Iir_Kind_Psl_Cover_Statement =>
            Rti_Const := Node_Info.Psl_Rti_Const;
         when others =>
            Error_Kind ("get_context_rti", Node);
      end case;
      return New_Rti_Address (Rti_Const);
   end Get_Context_Rti;

   function Get_Context_Addr (Node : Iir) return O_Enode
   is
      Node_Info : constant Ortho_Info_Acc := Get_Info (Node);
      Ref       : O_Lnode;
   begin
      case Get_Kind (Node) is
         when Iir_Kind_Component_Declaration =>
            Ref := Get_Instance_Ref (Node_Info.Comp_Scope);
         when Iir_Kind_Entity_Declaration
            | Iir_Kind_Architecture_Body
            | Iir_Kind_Block_Statement
            | Iir_Kind_Generate_Statement =>
            Ref := Get_Instance_Ref (Node_Info.Block_Scope);
         when Iir_Kind_Package_Declaration
            | Iir_Kind_Package_Body =>
            return New_Lit (New_Null_Access (Ghdl_Ptr_Type));
         when Iir_Kind_Process_Statement
            | Iir_Kind_Sensitized_Process_Statement =>
            Ref := Get_Instance_Ref (Node_Info.Process_Scope);
         when Iir_Kind_Psl_Assert_Statement
            | Iir_Kind_Psl_Cover_Statement =>
            Ref := Get_Instance_Ref (Node_Info.Psl_Scope);
         when others =>
            Error_Kind ("get_context_addr", Node);
      end case;
      return New_Unchecked_Address (Ref, Ghdl_Ptr_Type);
   end Get_Context_Addr;

   procedure Associate_Rti_Context (Assoc : in out O_Assoc_List; Node : Iir)
   is
   begin
      New_Association (Assoc, New_Lit (Get_Context_Rti (Node)));
      New_Association (Assoc, Get_Context_Addr (Node));
   end Associate_Rti_Context;

   procedure Associate_Null_Rti_Context (Assoc : in out O_Assoc_List) is
   begin
      New_Association (Assoc, New_Lit (New_Null_Access (Ghdl_Rti_Access)));
      New_Association (Assoc, New_Lit (New_Null_Access (Ghdl_Ptr_Type)));
   end Associate_Null_Rti_Context;
end Trans.Rtis;