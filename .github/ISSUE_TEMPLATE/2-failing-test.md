---
name: "💉 Failing Test"
about: Report failing tests, CI/CD pipeline jobs, or test suite issues
title: "[TEST] "
labels: "Type: Test", "Needs Triage"
assignees: "@TuxTechLab/team-qa", "@TuxTechLab/team-devops"
---

# 🚨 Failing Test Report

> ⚠️ **Before You Begin**  
> - Search existing issues to avoid duplicates
> - Check if this is a known issue in our [status page](https://status.tuxtechlab.com)
> - Ensure you're using the latest version of the codebase

## 📋 Basic Information

- **Test/Job Name**: 
- **Test File/Path**: 
- **Branch/Commit**: 
- **CI/CD Environment**: [e.g., GitHub Actions, Jenkins, CircleCI]
- **Run ID/URL**: 
- **First Observed**: [Date and time]
- **Frequency**: [Always/Intermittent/Specific conditions]

## 🔍 Detailed Description

### Expected Behavior
<!-- What should have happened? -->

### Actual Behavior
<!-- What actually happened? -->

### Error Message/Logs
```
Paste relevant error messages or logs here
```

## 🔧 Steps to Reproduce
1. 
2. 
3. 

## 📸 Screenshots/Logs
<!-- 
To attach screenshots:
1. Drag and drop images here or
2. Use this markdown:
   ```markdown
   ![Description](https://.../screenshot.png)
   ```
-->

## 🌍 Environment
- **OS**: [e.g., Windows 10, Ubuntu 20.04, macOS 12]
- **Browser**: [if applicable, e.g., Chrome 98, Firefox 97]
- **Node.js Version**: [if applicable]
- **Dependencies**: [any relevant dependency versions]

## 🔄 Related Issues/PRs
<!-- List any related issues or pull requests -->
- 
## 📝 Additional Context
<!-- Any other context about the problem -->

## ✅ Checklist
- [ ] I've searched for similar issues
- [ ] I've included all relevant information
- [ ] I've attached necessary screenshots/logs
- [ ] I've tested with the latest code

<!-- 
📌 NOTE: 
- For security-sensitive test failures, please email security@tuxtechlab.com
- Include the [SECURITY] prefix in the title for critical test failures
- @mention relevant team members if you know who should handle this
-->

<!-- Auto-closing keywords (remove if not needed) -->
/kind test-failure
/priority needs-triage
