# Pull Request Template

## Description

<!-- Provide a brief description of the changes -->

## Type of Change

<!-- Mark the relevant option with an "x" -->

- [ ] 🐛 Bug fix (non-breaking change which fixes an issue)
- [ ] ✨ New feature (non-breaking change which adds functionality)
- [ ] 💥 Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] 📝 Documentation update
- [ ] 🎨 Style/UI update (formatting, renaming, etc.)
- [ ] ♻️ Refactoring (no functional changes)
- [ ] ⚡ Performance improvement
- [ ] ✅ Test update
- [ ] 🔧 Configuration change
- [ ] 🔒 Security fix

## Related Issue

<!-- Link to the issue this PR addresses -->

Fixes #(issue number)

## Changes Made

<!-- List the specific changes made in this PR -->

- 
- 
- 

## Screenshots (if applicable)

<!-- Add screenshots to help explain your changes -->

| Before | After |
|--------|-------|
|        |       |

## Testing

<!-- Describe the tests you ran to verify your changes -->

### Test Configuration
- **Device/Browser**: 
- **OS**: 
- **Flutter/Node Version**: 

### Test Cases
- [ ] Test case 1
- [ ] Test case 2
- [ ] Test case 3

## Checklist

<!-- Mark completed items with an "x" -->

### Code Quality
- [ ] My code follows the style guidelines of this project
- [ ] I have performed a self-review of my own code
- [ ] I have commented my code, particularly in hard-to-understand areas
- [ ] My changes generate no new warnings
- [ ] I have checked for and removed any console.log statements

### Documentation
- [ ] I have made corresponding changes to the documentation
- [ ] I have updated the README.md if needed
- [ ] I have added/updated code comments where necessary

### Testing
- [ ] I have added tests that prove my fix is effective or that my feature works
- [ ] New and existing unit tests pass locally with my changes
- [ ] I have tested on multiple devices/browsers (if frontend change)

### Dependencies
- [ ] I have checked that no new dependencies were added unnecessarily
- [ ] All new dependencies are documented and justified
- [ ] I have run `npm audit` / `flutter pub outdated` to check for vulnerabilities

### Backend Changes (if applicable)
- [ ] Database migrations are included and tested
- [ ] API documentation is updated
- [ ] Backward compatibility is maintained
- [ ] Error handling is implemented

### Frontend Changes (if applicable)
- [ ] UI is responsive across different screen sizes
- [ ] Loading states are handled
- [ ] Error states are handled
- [ ] Accessibility standards are met

### Security
- [ ] I have checked for potential security vulnerabilities
- [ ] No sensitive data is exposed in logs or error messages
- [ ] Input validation is implemented where necessary
- [ ] Authentication/authorization is properly handled

## Performance Impact

<!-- Describe any performance implications -->

- [ ] No performance impact
- [ ] Improves performance
- [ ] May impact performance (explain below)

**Performance notes:**


## Breaking Changes

<!-- List any breaking changes and migration steps -->

- [ ] No breaking changes
- [ ] Contains breaking changes (list below)

**Breaking changes:**


**Migration guide:**


## Additional Notes

<!-- Add any other context about the PR here -->


## Reviewer Notes

<!-- Notes for reviewers -->

**Areas needing special attention:**
- 
- 

**Questions for reviewers:**
- 
- 

## Deployment Notes

<!-- Any special instructions for deployment -->

- [ ] No special deployment steps needed
- [ ] Requires environment variable changes
- [ ] Requires database migration
- [ ] Requires cache clearing
- [ ] Requires service restart

**Deployment instructions:**


---

## Post-Merge Checklist

<!-- To be completed after merge -->

- [ ] Verify deployment in staging
- [ ] Verify deployment in production
- [ ] Update relevant documentation
- [ ] Close related issues
- [ ] Notify stakeholders if needed
