#!/usr/bin/env bash

set -euo pipefail

FILE="project-44-kubernetes-rbac-hardening/manifests/rbac.yaml"

echo "=============================================="
echo "PROJECT 44 RBAC POLICY SECURITY GATE"
echo "=============================================="

test -f "$FILE"

ruby -e '
require "yaml"

documents = YAML.load_stream(File.read(ARGV[0]))
resources = documents.compact

roles = resources.select { |r| r["kind"] == "Role" }
bindings = resources.select { |r| r["kind"] == "RoleBinding" }
accounts = resources.select { |r| r["kind"] == "ServiceAccount" }

abort "Expected 3 ServiceAccounts" unless accounts.length == 3
abort "Expected 3 Roles" unless roles.length == 3
abort "Expected 3 RoleBindings" unless bindings.length == 3

resources.each do |resource|
  abort "ClusterRole forbidden" if resource["kind"] == "ClusterRole"
  abort "ClusterRoleBinding forbidden" if resource["kind"] == "ClusterRoleBinding"

  if resource["kind"] == "Role"
    resource.fetch("rules", []).each do |rule|
      verbs = rule.fetch("verbs", [])
      resources_list = rule.fetch("resources", [])

      abort "Wildcard verb detected" if verbs.include?("*")
      abort "Wildcard resource detected" if resources_list.include?("*")
      abort "Secret access detected" if resources_list.include?("secrets")

      forbidden = %w[
        roles
        rolebindings
        clusterroles
        clusterrolebindings
      ]

      if resources_list.any? { |item| forbidden.include?(item) }
        abort "RBAC administration permission detected"
      end
    end
  end
end

puts "✓ YAML structure valid"
puts "✓ 3 ServiceAccounts"
puts "✓ 3 namespace-scoped Roles"
puts "✓ 3 RoleBindings"
puts "✓ No ClusterRole"
puts "✓ No ClusterRoleBinding"
puts "✓ No wildcard permissions"
puts "✓ No Secret permissions"
puts "✓ No RBAC administration permissions"
' "$FILE"

echo
echo "=============================================="
echo "PROJECT 44 RBAC POLICY GATE: PASS"
echo "=============================================="
