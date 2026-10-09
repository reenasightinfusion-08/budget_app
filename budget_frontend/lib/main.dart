import 'package:flutter/material.dart';

import 'package:budget_frontend/app/app.dart';
import 'package:budget_frontend/core/network/api_client.dart';

void main() => runApp(BudgetApp(apiClient: ApiClient()));
