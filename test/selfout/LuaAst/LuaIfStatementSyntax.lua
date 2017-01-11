﻿-- Generated by CSharp.lua Compiler 1.0.0.0
local System = System;
System.namespace("CSharpLua.LuaAst", function (namespace) 
    namespace.class("LuaIfStatementSyntax", function (namespace) 
        local getCloseParenToken, getIfKeyword, getOpenParenToken, Render, __init__, __ctor__;
        __init__ = function (this) 
            this.Body = CSharpLua.LuaAst.LuaBlockSyntax();
        end;
        __ctor__ = function (this, condition) 
            __init__(this);
            if condition == nil then
                System.throw(System.ArgumentNullException("condition"));
            end
            this.Condition = condition;
        end;
        getCloseParenToken = function (this) 
            return "end" --[[Keyword.End]];
        end;
        getIfKeyword = function (this) 
            return "if" --[[Keyword.If]];
        end;
        getOpenParenToken = function (this) 
            return "then" --[[Keyword.Then]];
        end;
        Render = function (this, renderer) 
            renderer:Render(this);
        end;
        return {
            __inherits__ = {
                CSharpLua.LuaAst.LuaStatementSyntax
            }, 
            getCloseParenToken = getCloseParenToken, 
            getIfKeyword = getIfKeyword, 
            getOpenParenToken = getOpenParenToken, 
            Render = Render, 
            __ctor__ = __ctor__
        };
    end);
    namespace.class("LuaElseClauseSyntax", function (namespace) 
        local getElseKeyword, Render, __ctor__;
        __ctor__ = function (this, statement) 
            this.Statement = statement;
        end;
        getElseKeyword = function (this) 
            return "else" --[[Keyword.Else]];
        end;
        Render = function (this, renderer) 
            renderer:Render(this);
        end;
        return {
            __inherits__ = {
                CSharpLua.LuaAst.LuaSyntaxNode
            }, 
            getElseKeyword = getElseKeyword, 
            Render = Render, 
            __ctor__ = __ctor__
        };
    end);
    namespace.class("LuaSwitchAdapterStatementSyntax", function (namespace) 
        local Fill, CheckHasDefaultLabel, FindMatchIfStatement, CheckHasCaseLabel, Render, __init__, __ctor__;
        __init__ = function (this) 
            this.RepeatStatement = CSharpLua.LuaAst.LuaRepeatStatementSyntax(CSharpLua.LuaAst.LuaIdentifierNameSyntax.One);
            this.caseLabelVariables_ = CSharpLua.LuaAst.LuaLocalVariablesStatementSyntax();
            this.CaseLabels = System.Dictionary(System.Int, CSharpLua.LuaAst.LuaIdentifierNameSyntax)();
        end;
        __ctor__ = function (this, temp) 
            __init__(this);
            this.Temp = temp;
        end;
        Fill = function (this, expression, sections) 
            if expression == nil then
                System.throw(System.ArgumentNullException("expression"));
            end
            if sections == nil then
                System.throw(System.ArgumentNullException("sections"));
            end

            local body = this.RepeatStatement.Body;
            body.Statements:Add(this.caseLabelVariables_);
            local variableDeclarator = CSharpLua.LuaAst.LuaVariableDeclaratorSyntax(this.Temp);
            variableDeclarator.Initializer = CSharpLua.LuaAst.LuaEqualsValueClauseSyntax(expression);
            body.Statements:Add(CSharpLua.LuaAst.LuaLocalVariableDeclaratorSyntax(variableDeclarator));

            local ifHeadStatement = nil;
            local ifTailStatement = nil;
            for _, section in System.each(sections) do
                local statement = System.as(section, CSharpLua.LuaAst.LuaIfStatementSyntax);
                if statement ~= nil then
                    if ifTailStatement ~= nil then
                        ifTailStatement.Else = CSharpLua.LuaAst.LuaElseClauseSyntax(statement);
                    else
                        ifHeadStatement = statement;
                    end
                    ifTailStatement = statement;
                else
                    assert(this.defaultBock_ == nil);
                    this.defaultBock_ = System.cast(CSharpLua.LuaAst.LuaBlockSyntax, section);
                end
            end

            if ifHeadStatement ~= nil then
                body.Statements:Add(ifHeadStatement);
                if this.defaultBock_ ~= nil then
                    ifTailStatement.Else = CSharpLua.LuaAst.LuaElseClauseSyntax(this.defaultBock_);
                end
                this.headIfStatement_ = ifHeadStatement;
            else
                if this.defaultBock_ ~= nil then
                    body.Statements:AddRange(this.defaultBock_.Statements);
                end
            end
        end;
        CheckHasDefaultLabel = function (this) 
            if this.DefaultLabel ~= nil then
                assert(this.defaultBock_ ~= nil);
                this.caseLabelVariables_.Variables:Add(this.DefaultLabel);
                local labeledStatement = CSharpLua.LuaAst.LuaLabeledStatement(this.DefaultLabel);
                this.RepeatStatement.Body.Statements:Add(labeledStatement);
                local IfStatement = CSharpLua.LuaAst.LuaIfStatementSyntax(this.DefaultLabel);
                IfStatement.Body.Statements:AddRange(this.defaultBock_.Statements);
                this.RepeatStatement.Body.Statements:Add(IfStatement);
            end
        end;
        FindMatchIfStatement = function (this, index) 
            local head = this.headIfStatement_;
            local counter = 0;
            while true do
                if counter == index then
                    return head;
                end
                head = System.cast(CSharpLua.LuaAst.LuaIfStatementSyntax, head.Else.Statement);
                counter = counter + 1;
            end
        end;
        CheckHasCaseLabel = function (this) 
            if this.CaseLabels:getCount() > 0 then
                assert(this.headIfStatement_ ~= nil);
                this.caseLabelVariables_.Variables:AddRange(this.CaseLabels:getValues());
                for _, pair in System.each(this.CaseLabels) do
                    local caseLabelStatement = FindMatchIfStatement(this, pair:getKey());
                    local labelIdentifier = pair:getValue();
                    this.RepeatStatement.Body.Statements:Add(CSharpLua.LuaAst.LuaLabeledStatement(labelIdentifier));
                    local ifStatement = CSharpLua.LuaAst.LuaIfStatementSyntax(labelIdentifier);
                    ifStatement.Body.Statements:AddRange(caseLabelStatement.Body.Statements);
                    this.RepeatStatement.Body.Statements:Add(ifStatement);
                end
            end
        end;
        Render = function (this, renderer) 
            CheckHasCaseLabel(this);
            CheckHasDefaultLabel(this);
            renderer:Render(this);
        end;
        return {
            __inherits__ = {
                CSharpLua.LuaAst.LuaStatementSyntax
            }, 
            Fill = Fill, 
            Render = Render, 
            __ctor__ = __ctor__
        };
    end);
end);