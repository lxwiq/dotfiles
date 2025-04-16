-- Angular specific plugins and configuration

return {
  -- Angular language server is configured in lsp.lua

  -- Angular template syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "angular" })
      end
    end,
  },

  -- Angular snippets
  {
    "L3MON4D3/LuaSnip",
    config = function()
      -- Create a directory for Angular snippets
      local snippets_dir = vim.fn.stdpath("config") .. "/snippets/angular"
      vim.fn.mkdir(snippets_dir, "p")

      -- Create Angular component snippet
      local angular_component = [[
{
  "Angular Component": {
    "prefix": "ng-component",
    "body": [
      "import { Component, OnInit } from '@angular/core';",
      "",
      "@Component({",
      "  selector: '${1:app-component-name}',",
      "  templateUrl: './${2:component-name}.component.html',",
      "  styleUrls: ['./${2:component-name}.component.scss']",
      "})",
      "export class ${3:ComponentName}Component implements OnInit {",
      "",
      "  constructor() { }",
      "",
      "  ngOnInit(): void {",
      "    $0",
      "  }",
      "}",
      ""
    ],
    "description": "Angular Component"
  }
}
      ]]

      -- Create Angular service snippet
      local angular_service = [[
{
  "Angular Service": {
    "prefix": "ng-service",
    "body": [
      "import { Injectable } from '@angular/core';",
      "",
      "@Injectable({",
      "  providedIn: 'root'",
      "})",
      "export class ${1:Service}Service {",
      "",
      "  constructor() { }",
      "  ",
      "  $0",
      "}",
      ""
    ],
    "description": "Angular Service"
  }
}
      ]]

      -- Create Angular module snippet
      local angular_module = [[
{
  "Angular Module": {
    "prefix": "ng-module",
    "body": [
      "import { NgModule } from '@angular/core';",
      "import { CommonModule } from '@angular/common';",
      "",
      "@NgModule({",
      "  declarations: [$1],",
      "  imports: [",
      "    CommonModule$2",
      "  ],",
      "  exports: [$3],",
      "  providers: [$4]",
      "})",
      "export class ${5:Name}Module { }",
      ""
    ],
    "description": "Angular Module"
  }
}
      ]]

      -- Create Angular directive snippet
      local angular_directive = [[
{
  "Angular Directive": {
    "prefix": "ng-directive",
    "body": [
      "import { Directive, ElementRef, HostListener, Input } from '@angular/core';",
      "",
      "@Directive({",
      "  selector: '[${1:appDirective}]'",
      "})",
      "export class ${2:Directive}Directive {",
      "  @Input() ${1:appDirective}: string;",
      "",
      "  constructor(private el: ElementRef) { }",
      "",
      "  @HostListener('mouseenter') onMouseEnter() {",
      "    this.highlight('yellow');",
      "  }",
      "",
      "  @HostListener('mouseleave') onMouseLeave() {",
      "    this.highlight(null);",
      "  }",
      "",
      "  private highlight(color: string) {",
      "    this.el.nativeElement.style.backgroundColor = color;",
      "  }",
      "}",
      ""
    ],
    "description": "Angular Directive"
  }
}
      ]]

      -- Create Angular pipe snippet
      local angular_pipe = [[
{
  "Angular Pipe": {
    "prefix": "ng-pipe",
    "body": [
      "import { Pipe, PipeTransform } from '@angular/core';",
      "",
      "@Pipe({",
      "  name: '${1:pipe}'",
      "})",
      "export class ${2:Pipe}Pipe implements PipeTransform {",
      "  transform(value: any, ...args: any[]): any {",
      "    return $0;",
      "  }",
      "}",
      ""
    ],
    "description": "Angular Pipe"
  }
}
      ]]

      -- Create Angular guard snippet
      local angular_guard = [[
{
  "Angular Guard": {
    "prefix": "ng-guard",
    "body": [
      "import { Injectable } from '@angular/core';",
      "import { ActivatedRouteSnapshot, CanActivate, RouterStateSnapshot, UrlTree, Router } from '@angular/router';",
      "import { Observable } from 'rxjs';",
      "",
      "@Injectable({",
      "  providedIn: 'root'",
      "})",
      "export class ${1:Auth}Guard implements CanActivate {",
      "  constructor(private router: Router) {}",
      "",
      "  canActivate(",
      "    route: ActivatedRouteSnapshot,",
      "    state: RouterStateSnapshot",
      "  ): Observable<boolean | UrlTree> | Promise<boolean | UrlTree> | boolean | UrlTree {",
      "    $0",
      "    return true;",
      "  }",
      "}",
      ""
    ],
    "description": "Angular Guard"
  }
}
      ]]

      -- Create Angular resolver snippet
      local angular_resolver = [[
{
  "Angular Resolver": {
    "prefix": "ng-resolver",
    "body": [
      "import { Injectable } from '@angular/core';",
      "import { Resolve, ActivatedRouteSnapshot, RouterStateSnapshot } from '@angular/router';",
      "import { Observable } from 'rxjs';",
      "",
      "@Injectable({",
      "  providedIn: 'root'",
      "})",
      "export class ${1:Data}Resolver implements Resolve<${2:any}> {",
      "  constructor() {}",
      "",
      "  resolve(",
      "    route: ActivatedRouteSnapshot,",
      "    state: RouterStateSnapshot",
      "  ): Observable<${2:any}> | Promise<${2:any}> | ${2:any} {",
      "    $0",
      "    return ${3:data};",
      "  }",
      "}",
      ""
    ],
    "description": "Angular Resolver"
  }
}
      ]]

      -- Create Angular interceptor snippet
      local angular_interceptor = [[
{
  "Angular Interceptor": {
    "prefix": "ng-interceptor",
    "body": [
      "import { Injectable } from '@angular/core';",
      "import { HttpRequest, HttpHandler, HttpEvent, HttpInterceptor } from '@angular/common/http';",
      "import { Observable } from 'rxjs';",
      "",
      "@Injectable()",
      "export class ${1:Auth}Interceptor implements HttpInterceptor {",
      "  constructor() {}",
      "",
      "  intercept(request: HttpRequest<unknown>, next: HttpHandler): Observable<HttpEvent<unknown>> {",
      "    $0",
      "    return next.handle(request);",
      "  }",
      "}",
      ""
    ],
    "description": "Angular Interceptor"
  }
}
      ]]

      -- Write snippets to files
      local function write_snippet(filename, content)
        local file = io.open(snippets_dir .. "/" .. filename, "w")
        if file then
          file:write(content)
          file:close()
        end
      end

      write_snippet("component.json", angular_component)
      write_snippet("service.json", angular_service)
      write_snippet("module.json", angular_module)
      write_snippet("directive.json", angular_directive)
      write_snippet("pipe.json", angular_pipe)
      write_snippet("guard.json", angular_guard)
      write_snippet("resolver.json", angular_resolver)
      write_snippet("interceptor.json", angular_interceptor)
    end,
  },

  -- Angular file templates
  {
    "glepnir/template.nvim",
    cmd = { "Template", "TemProject" },
    config = function()
      require("template").setup({
        temp_dir = vim.fn.stdpath("config") .. "/templates",
        author = "User",
        email = "user@example.com",
      })

      -- Create templates directory
      local templates_dir = vim.fn.stdpath("config") .. "/templates"
      vim.fn.mkdir(templates_dir, "p")

      -- Create Angular component template files
      local component_ts = [[
import { Component, OnInit } from '@angular/core';

@Component({
  selector: 'app-{{_file_name}}',
  templateUrl: './{{_file_name}}.component.html',
  styleUrls: ['./{{_file_name}}.component.scss']
})
export class {{_file_name | capitalize}}Component implements OnInit {

  constructor() { }

  ngOnInit(): void {
  }

}
]]

      local component_html = [[
<div>
  {{_file_name}} works!
</div>
]]

      local component_scss = [[
:host {
  display: block;
}
]]

      -- Write templates to files
      local function write_template(filename, content)
        local file = io.open(templates_dir .. "/" .. filename, "w")
        if file then
          file:write(content)
          file:close()
        end
      end

      write_template("angular-component.ts", component_ts)
      write_template("angular-component.html", component_html)
      write_template("angular-component.scss", component_scss)
    end,
  },
}
