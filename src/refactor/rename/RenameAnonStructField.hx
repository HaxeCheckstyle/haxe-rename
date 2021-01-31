package refactor.rename;

import refactor.RefactorContext;
import refactor.RefactorResult;
import refactor.discover.File;
import refactor.discover.Identifier;
import refactor.discover.IdentifierType.TypedefFieldType;
import refactor.discover.Type;
import refactor.edits.Changelist;

class RenameAnonStructField {
	public static function refactorAnonStructField(context:RefactorContext, file:File, identifier:Identifier, fields:Array<TypedefFieldType>):RefactorResult {
		var changelist:Changelist = new Changelist(context);
		var packName:String = file.getPackage();
		var mainModuleName = file.getMainModulName();

		changelist.addChange(identifier.pos.fileName, ReplaceText(context.what.toName, identifier.pos), identifier);

		renameFieldsOfType(context, changelist, identifier.defineType, fields, identifier.name);

		return changelist.execute();
	}

	public static function refactorStructureField(context:RefactorContext, file:File, identifier:Identifier, fieldNames:Array<String>):RefactorResult {
		var allUses:Array<Identifier> = context.nameMap.getIdentifiers(identifier.name);
		for (use in allUses) {
			switch (use.type) {
				case TypedefField(fields):
					fields = fields.concat(findBaseTypes(context, use.defineType));
					if (matchesFields(fields, fieldNames)) {
						return refactorAnonStructField(context, use.file, use, fields);
					}
				default:
					continue;
			}
		}
		return Unsupported(identifier.toString());
	}

	static function renameFieldsOfType(context:RefactorContext, changelist:Changelist, type:Type, fields:Array<TypedefFieldType>, fromName:String) {
		var packName:String = type.file.getPackage();
		var mainModuleName = type.file.getMainModulName();
		fields = fields.concat(findBaseTypes(context, type));

		var allUses:Array<Identifier> = context.nameMap.matchIdentifierPart(fromName, true);
		for (use in allUses) {
			switch (use.type) {
				case StructureField(fieldNames):
					if (!matchesFields(fields, fieldNames)) {
						continue;
					}
				case Call(false) | Access:
					RenameHelper.replaceSingleAccessOrCall(context, changelist, use, fromName, [type]);
					continue;
				default:
					continue;
			}
			switch (use.file.importsModule(packName, mainModuleName, type.name.name)) {
				case None:
					continue;
				case Global | SamePackage | Imported | ImportedWithAlias(_):
			}
			changelist.addChange(use.pos.fileName, ReplaceText(context.what.toName, use.pos), use);
		}

		findAllExtending(context, changelist, type, fields, fromName);
	}

	static function findAllExtending(context:RefactorContext, changelist:Changelist, type:Type, fields:Array<TypedefFieldType>, fromName:String) {
		var allUses:Array<Identifier> = context.nameMap.getIdentifiers(type.name.name);
		for (use in allUses) {
			switch (use.type) {
				case TypedefBase:
					renameFieldsOfType(context, changelist, use.defineType, getFieldsOfTypedef(use.defineType), fromName);
				default:
			}
		}
	}

	static function matchesFields(fields:Array<TypedefFieldType>, fieldNames:Array<String>):Bool {
		var allowedFieldNames:Array<String> = [];
		for (field in fields) {
			switch (field) {
				case Required(identifier):
					allowedFieldNames.push(identifier.name);
					if (!fieldNames.contains(identifier.name)) {
						return false;
					}
				case Optional(identifier):
					allowedFieldNames.push(identifier.name);
			}
		}
		for (fieldName in fieldNames) {
			if (!allowedFieldNames.contains(fieldName)) {
				return false;
			}
		}
		return true;
	}

	static function findBaseTypes(context:RefactorContext, type:Type):Array<TypedefFieldType> {
		var fieldTypes:Array<TypedefFieldType> = [];
		var baseTypes:Array<Identifier> = type.findAllIdentifiers((i) -> i.type.match(TypedefBase));
		for (baseTypeName in baseTypes) {
			var base:Null<Type> = findBase(context, baseTypeName);
			if (base == null) {
				continue;
			}
			fieldTypes = fieldTypes.concat(getFieldsOfTypedef(base));
		}
		return fieldTypes;
	}

	static function getFieldsOfTypedef(type:Type):Array<TypedefFieldType> {
		var allChilds:Array<Identifier> = type.findAllIdentifiers((i) -> true);
		for (child in allChilds) {
			switch (child.type) {
				case TypedefField(fields):
					return fields;
				default:
			}
		}
		return [];
	}

	static function findBase(context:RefactorContext, baseTypeName:Identifier):Null<Type> {
		var allUses:Array<Identifier> = context.nameMap.getIdentifiers(baseTypeName.name);
		for (use in allUses) {
			switch (use.type) {
				case Typedef:
				default:
					continue;
			}
			switch (baseTypeName.file.importsModule(use.file.getPackage(), use.file.getMainModulName(), baseTypeName.name)) {
				case None:
					continue;
				case Global | SamePackage | Imported | ImportedWithAlias(_):
			}
			return use.defineType;
		}
		return null;
	}
}
