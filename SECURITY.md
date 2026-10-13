# Security and Responsible Reporting

New Hope is not currently a functioning or supported operating system. Its mandatory UMI enforcement, privilege boundaries, and fault-isolation properties are **design requirements**, not implemented guarantees.

For security-sensitive findings, avoid posting exploit payloads, credentials, or sensitive logs in public issues. Contact the repository owner through an appropriate private GitHub channel if one is provided. A public issue is appropriate for non-sensitive design defects and test gaps.

Security changes must preserve the microkernel boundary, least privilege, UMI default-deny behavior, and recorded negative test results. Never respond to a test failure by quietly disabling an enforcement check.
